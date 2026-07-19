// MedalCase — module build orchestration.
// Committed pipeline artifact: builds modules in dependency tiers, each flowing
// spec → tests-first → implement → build/test → adversarial verify, with a bounded
// repair loop and worktree isolation. Run ONLY with explicit go-ahead (see CLAUDE.md).
export const meta = {
  name: 'build-modules',
  description: 'Build MedalCase modules in dependency tiers via spec→tests→implement→verify with a repair loop',
  phases: [
    { title: 'Foundation tier', detail: 'MedalDomain ∥ DesignSystem' },
    { title: 'Data tier', detail: 'MedalData (bundled JSON + repository seam)' },
    { title: 'Feature tier', detail: 'AchievementsFeature (grid + ViewModel)' },
  ],
}

// Structured verdict from the adversarial reviewer — drives the repair loop.
const VERDICT_SCHEMA = {
  type: 'object',
  required: ['pass', 'findings'],
  properties: {
    pass: { type: 'boolean' },
    findings: {
      type: 'array',
      items: {
        type: 'object',
        required: ['severity', 'location', 'issue', 'fix'],
        properties: {
          severity: { enum: ['blocker', 'major', 'minor'] },
          location: { type: 'string' },
          issue: { type: 'string' },
          fix: { type: 'string' },
        },
      },
    },
  },
}

// Dependency-tiered plan: tiers run in order; modules within a tier run in parallel.
const TIERS = [
  { phase: 'Foundation tier', modules: ['MedalDomain', 'DesignSystem'] },
  { phase: 'Data tier', modules: ['MedalData'] },
  { phase: 'Feature tier', modules: ['AchievementsFeature'] },
]

const MAX_REPAIRS = 2

const builderFor = (module) =>
  module.endsWith('Feature') || module === 'DesignSystem'
    ? 'swiftui-component-builder'
    : 'swift-module-builder'

// One module: TDD red → (implement → verify) with a bounded repair loop, worktree-isolated.
async function buildModule(module, phase) {
  await agent(
    `Operate /tdd RED for ${module}: from tech_specs/modules/${module}.md, write failing Swift Testing ` +
      `tests + dedicated MedalTestSupport mocks. Do NOT implement; confirm they fail for the right reason.`,
    { agentType: 'test-author', phase, label: `${module}: tests`, isolation: 'worktree' },
  )

  let findings = ''
  for (let attempt = 0; attempt <= MAX_REPAIRS; attempt++) {
    const tag = attempt ? ` (repair ${attempt})` : ''
    await agent(
      `Operate /tdd GREEN for ${module}: implement to pass the failing tests, honoring CLAUDE.md ` +
        `(dependency rule, no force-unwrap, constructor DI, Swift 6 concurrency, the battery rule). ` +
        `Build + test via swift test --package-path Modules/${module}.` +
        (findings ? `\nFix these review findings from the previous attempt:\n${findings}` : ''),
      { agentType: builderFor(module), phase, label: `${module}: implement${tag}`, isolation: 'worktree' },
    )

    const verdict = await agent(
      `Operate /ios-review on Modules/${module}: adversarial review vs CLAUDE.md and the spec.`,
      { agentType: 'swift-reviewer', phase, label: `${module}: verify${tag}`, schema: VERDICT_SCHEMA },
    )

    if (!verdict || verdict.pass) return { module, pass: !!(verdict && verdict.pass), attempts: attempt }
    findings = (verdict.findings || [])
      .map((f) => `- [${f.severity}] ${f.location}: ${f.issue} → ${f.fix}`)
      .join('\n')
    log(`${module}: review FAILED (attempt ${attempt + 1}) — ${verdict.findings?.length ?? 0} findings; repairing`)
  }
  log(`${module}: still failing after ${MAX_REPAIRS} repairs — needs human attention`)
  return { module, pass: false, attempts: MAX_REPAIRS + 1 }
}

const results = []
for (const tier of TIERS) {
  phase(tier.phase)
  log(`Tier "${tier.phase}": ${tier.modules.join(' ∥ ')}`)
  const tierResults = await parallel(tier.modules.map((m) => () => buildModule(m, tier.phase)))
  results.push(...tierResults.filter(Boolean))
  const failed = tierResults.filter((r) => r && !r.pass)
  if (failed.length) {
    log(`Halting before next tier: ${failed.map((f) => f.module).join(', ')} did not pass review.`)
    break
  }
}

return { results }
