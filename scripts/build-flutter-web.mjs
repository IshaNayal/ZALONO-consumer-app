/**
 * Builds the Flutter web app that the Express server hosts at the root.
 *
 * Render's Node image ships no Flutter SDK, so this script is deliberately
 * self-sufficient: it finds a usable SDK and, failing that, downloads one.
 * Keeping the lookup here means `npm run build` works whether it is invoked
 * locally, from a CI job, or from a build command that never touched `PATH`.
 */
import { spawnSync } from 'node:child_process';
import { existsSync, mkdirSync } from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const appDir = path.join(repoRoot, 'flutter_zalono');
const vendoredSdk = path.join(repoRoot, '.flutter-sdk');
const channel = process.env.FLUTTER_CHANNEL || 'stable';
const isWindows = process.platform === 'win32';

const flutterBin = (sdkRoot) =>
  isWindows ? path.join(sdkRoot, 'bin', 'flutter.bat') : path.join(sdkRoot, 'bin', 'flutter');

const candidates = () =>
  [
    process.env.FLUTTER_ROOT,
    vendoredSdk,
    isWindows ? 'C:\\src\\flutter' : '/opt/flutter',
    path.join(process.env.HOME || '', 'flutter'),
    '/usr/local/flutter'
  ].filter(Boolean);

function isSdk(root) {
  try {
    return existsSync(flutterBin(root));
  } catch {
    return false;
  }
}

/** The SDK already on PATH, if any. */
function sdkOnPath() {
  const probe = isWindows ? 'flutter.bat' : 'flutter';
  const result = spawnSync(isWindows ? 'where' : 'which', [probe], { encoding: 'utf8' });
  if (result.status !== 0) return null;

  const first = result.stdout.split(/\r?\n/).find((line) => line.trim().length > 0);
  if (!first) return null;

  // .../bin/flutter -> .../
  const root = path.resolve(path.dirname(first.trim()), '..');
  return isSdk(root) ? root : null;
}

function findSdk() {
  if (process.env.FLUTTER_ROOT) {
    if (!isSdk(process.env.FLUTTER_ROOT)) {
      throw new Error(
        `FLUTTER_ROOT is set to "${process.env.FLUTTER_ROOT}" but no Flutter binary is there.`
      );
    }
    return process.env.FLUTTER_ROOT;
  }

  for (const root of candidates()) {
    if (isSdk(root)) return root;
  }

  return sdkOnPath();
}

function ensureSdk() {
  const existing = findSdk();
  if (existing) {
    console.log(`[build] Using Flutter SDK at ${existing}`);
    return existing;
  }

  console.log(`[build] No Flutter SDK found, downloading ${channel} into .flutter-sdk ...`);
  mkdirSync(repoRoot, { recursive: true });

  const clone = spawnSync(
    'git',
    [
      'clone',
      '--depth',
      '1',
      '--branch',
      channel,
      'https://github.com/flutter/flutter.git',
      vendoredSdk
    ],
    { stdio: 'inherit' }
  );
  if (clone.status !== 0) {
    throw new Error('Could not download the Flutter SDK. Is git installed and is the network reachable?');
  }

  // Newer git refuses to read a repository owned by another user, which the
  // clone inside a container often is.
  spawnSync('git', ['config', '--global', '--add', 'safe.directory', vendoredSdk]);

  if (!isSdk(vendoredSdk)) {
    throw new Error(`The Flutter SDK was cloned to ${vendoredSdk} but its binary is missing.`);
  }

  return vendoredSdk;
}

/** Runs a command, quoting arguments so paths containing spaces survive. */
function run(command, args, cwd = repoRoot) {
  const useShell = isWindows && /\.(bat|cmd)$/i.test(command);
  const commandLine = [command, ...args]
    .map((arg) => (/[\s&|<>^]/.test(arg) ? `"${arg}"` : arg))
    .join(' ');

  const result = spawnSync(useShell ? commandLine : command, useShell ? [] : args, {
    stdio: 'inherit',
    cwd,
    shell: useShell
  });

  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${path.basename(command)} exited with code ${result.status}`);
  }
}

const sdkRoot = ensureSdk();
const flutter = flutterBin(sdkRoot);

run(flutter, ['--version']);
run(flutter, ['pub', 'get'], appDir);
run(flutter, ['build', 'web', '--release', '--no-wasm-dry-run'], appDir);

console.log(`[build] Flutter web output: ${path.join(appDir, 'build', 'web')}`);