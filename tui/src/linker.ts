import {
  symlinkSync,
  mkdirSync,
  existsSync,
  lstatSync,
  realpathSync,
  renameSync,
  unlinkSync,
} from "fs";
import { join, dirname, relative, resolve } from "path";
import { walkFiles } from "./detect";

interface LinkerOptions {
  dotfilesDir: string;
  homeDir: string;
  log: (msg: string) => void;
}

export function link(pkg: string, opts: LinkerOptions): void {
  const pkgDir = join(opts.dotfilesDir, pkg);
  const files = walkFiles(pkgDir);

  for (const file of files) {
    const rel = relative(pkgDir, file);
    const linkPath = join(opts.homeDir, rel);

    mkdirSync(dirname(linkPath), { recursive: true });

    if (existsSync(linkPath)) {
      if (lstatSync(linkPath).isSymbolicLink()) {
        const resolved = realpathSync(linkPath);
        if (resolved === resolve(file)) continue;
        // Symlink points elsewhere — remove it
        unlinkSync(linkPath);
      } else {
        // Adopt: move existing file into repo, then symlink
        opts.log(`Adopting existing ${rel}...`);
        renameSync(linkPath, file);
      }
    }

    symlinkSync(resolve(file), linkPath, "file");
    opts.log(`Linked ${rel}`);
  }
}

export function unlink(pkg: string, opts: LinkerOptions): void {
  const pkgDir = join(opts.dotfilesDir, pkg);
  const files = walkFiles(pkgDir);

  for (const file of files) {
    const rel = relative(pkgDir, file);
    const linkPath = join(opts.homeDir, rel);

    if (existsSync(linkPath) && lstatSync(linkPath).isSymbolicLink()) {
      const resolved = realpathSync(linkPath);
      if (resolved === resolve(file)) {
        unlinkSync(linkPath);
        opts.log(`Unlinked ${rel}`);
      }
    }
  }
}

export function isLinked(dotfilesDir: string, pkg: string, homeDir: string): boolean {
  const pkgDir = join(dotfilesDir, pkg);
  if (!existsSync(pkgDir)) return false;

  const files = walkFiles(pkgDir);
  if (files.length === 0) return false;

  const firstFile = files[0];
  const rel = relative(pkgDir, firstFile);
  const linkPath = join(homeDir, rel);

  if (!existsSync(linkPath)) return false;

  try {
    const realPath = realpathSync(linkPath);
    return realPath.startsWith(dotfilesDir);
  } catch {
    return false;
  }
}
