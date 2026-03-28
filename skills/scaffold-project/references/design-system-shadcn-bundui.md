# Frontend design system: shadcn-style + Bundui reference kits

Use this document when the stack is **React + Vite + TypeScript + Tailwind** with **shadcn/ui-style** components (Radix + Tailwind + `cn()` patterns).

## Reference repositories (source of truth for patterns)

| Surface | Repository | Role |
|--------|------------|------|
| Marketing / landing / public site | [bundui/cosmic](https://github.com/bundui/cosmic) | Layout, sections, hero, pricing, FAQ, footers—**Cosmic** patterns |
| Authenticated app / dashboard / admin | [bundui/shadcn-ui-kit-dashboard](https://github.com/bundui/shadcn-ui-kit-dashboard) | Shell, sidebar, tables, cards, data UI—**Dashboard kit** patterns |

Study these repos for **composition, spacing rhythm, typography scale, component choice, and token usage**. Prefer their primitives and patterns over ad-hoc one-offs when building comparable UI.

## Rules

1. **Strict alignment** — Same design language as the relevant kit: use equivalent components, density, and hierarchy unless the PRD or mockups explicitly require something else.
2. **PRD and mockups win** — If requirements or `/mockups` conflict with a kit default, follow the product spec first; then reconcile with kit patterns where possible.
3. **Differentiate across projects** — Avoid copy-paste “template look” between products:
   - **Visual / branding:** color roles, type pairing, border radius, shadows, motion, imagery, and empty states should reflect *this* product’s brand.
   - **Structural / IA:** navigation model (top vs sidebar vs hybrid), content order, section emphasis, and dashboard density may differ as long as they stay within the same **shadcn + kit** vocabulary.

## Stack constraint

Do not assume Next.js App Router unless the PRD says so. Adapt kit examples to **Vite + React Router** (client routing, `VITE_*` env, no RSC).

## Practical workflow

- **New landing or marketing page** — Sketch structure against Cosmic; implement with this repo’s shadcn setup and Tailwind tokens.
- **New app shell or data-heavy screen** — Sketch against the Dashboard kit; same implementation approach.
- **Ambiguous** — If a screen is both (e.g. logged-out dashboard preview), split concerns: marketing blocks from Cosmic, interactive chrome from the Dashboard kit where it fits.
