import type { DotfilesModule } from "./types";

export function resolveDependencies(
  moduleId: string,
  allModules: DotfilesModule[],
  selected: Set<string>,
): string[] {
  const added: string[] = [];
  const mod = allModules.find((m) => m.id === moduleId);
  if (!mod?.dependencies) return added;

  for (const depId of mod.dependencies) {
    if (!selected.has(depId)) {
      added.push(depId);
      // Recursively resolve transitive deps
      added.push(...resolveDependencies(depId, allModules, new Set([...selected, ...added])));
    }
  }
  return [...new Set(added)];
}

export function checkDependents(
  moduleId: string,
  allModules: DotfilesModule[],
  selected: Set<string>,
): string[] {
  return allModules
    .filter((m) => selected.has(m.id) && m.dependencies?.includes(moduleId))
    .map((m) => m.id);
}

export function topologicalSort(
  moduleIds: string[],
  allModules: DotfilesModule[],
): string[] {
  const moduleMap = new Map(allModules.map((m) => [m.id, m]));
  const visited = new Set<string>();
  const result: string[] = [];

  function visit(id: string) {
    if (visited.has(id)) return;
    visited.add(id);

    const mod = moduleMap.get(id);
    if (mod?.dependencies) {
      for (const depId of mod.dependencies) {
        if (moduleIds.includes(depId)) visit(depId);
      }
    }
    result.push(id);
  }

  for (const id of moduleIds) visit(id);
  return result;
}

export function reverseTopologicalSort(
  moduleIds: string[],
  allModules: DotfilesModule[],
): string[] {
  return topologicalSort(moduleIds, allModules).reverse();
}

export function hasConflicts(
  moduleId: string,
  allModules: DotfilesModule[],
  selected: Set<string>,
): string[] {
  const mod = allModules.find((m) => m.id === moduleId);
  if (!mod?.conflicts) return [];
  return mod.conflicts.filter((c) => selected.has(c));
}
