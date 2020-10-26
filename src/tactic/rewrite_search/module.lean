/-
Copyright (c) 2020 Kevin Lacker, Keeley Hoek, Scott Morrison. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Kevin Lacker, Keeley Hoek, Scott Morrison
-/

import tactic.rewrite_search.core

import tactic.rewrite_search.strategy.bfs -- FIXME: remove this block

/-!
# Configuration and wrapper functions for rewrite search.
-/

namespace tactic.rewrite_search

meta def pick_default_strategy : tactic unit :=
`[exact tactic.rewrite_search.strategy.bfs]

structure collect_cfg :=
(suggest         : list name := [])
(inflate_rws     : bool := ff)
(help_me         : bool := ff)

/-
This is the "public" config structure which has convenient tactic-mode
invocation syntax. The data in this structure is extracted and transformed
into the internal representation of the settings and modules by
`try_mk_search_instance`.
-/
meta structure config (α β γ δ : Type) extends collect_cfg, tactic.nth_rewrite.cfg :=
(max_iterations     : ℕ := 500)
(optimal            : bool := tt)
(exhaustive         : bool := ff)
(trace              : bool := ff)
(trace_summary      : bool := ff)
(trace_rules        : bool := ff)
(explain            : bool := ff)
(explain_using_conv : bool := tt)
(strategy           : strategy_constructor α . pick_default_strategy)

open tactic.rewrite_search.strategy.bfs

meta def default_config : config bfs_state unit unit unit := {}
meta def pick_default_config : tactic unit := `[exact tactic.rewrite_search.default_config]

variables {α β γ δ : Type}

meta def mk_initial_search_state (conf : core_cfg) (rw_cfg : tactic.nth_rewrite.cfg)
  (rs : list (expr × bool)) (s : strategy α β γ δ) (strat_state : α) :
  search_state α β γ δ :=
⟨conf, rw_cfg, rs, strat_state, table.create, table.create,
 table.create, none, statistics.init⟩

meta def setup_instance (conf : core_cfg) (rw_cfg : tactic.nth_rewrite.cfg)
  (rs : list (expr × bool)) (s : strategy α β γ δ) (s_state : α) (eqn : sided_pair expr) :
  tactic (inst α β γ δ) :=
do let g := mk_initial_search_state conf rw_cfg rs s s_state,
   (g, vl) ← g.add_root_vertex eqn.l side.L,
   (g, vr) ← g.add_root_vertex eqn.r side.R,
   g ← s.startup g vl vr,
   return ⟨s, g⟩

meta def instantiate_modules (cfg : config α β γ δ) : strategy α β γ δ :=
(cfg.strategy β γ δ)

meta def try_mk_search_instance (cfg : config α β γ δ)
  (rs : list (expr × bool)) (eqn : sided_pair expr) : tactic (option (inst α β γ δ)) :=
do let (s) := instantiate_modules cfg,
   init_result.try "strategy" s.init $ λ strat_state, do
   let conf : core_cfg := {
    max_iterations := cfg.max_iterations,
    optimal := cfg.optimal,
    exhaustive := cfg.exhaustive,
    trace := cfg.trace,
    trace_summary := cfg.trace_summary,
    trace_rules := cfg.trace_rules,
    explain := cfg.explain,
    explain_using_conv := cfg.explain_using_conv
  },
  option.some <$>
    setup_instance conf cfg.to_cfg rs s strat_state eqn

open tactic

meta def try_search (cfg : config α β γ δ)
  (rs : list (expr × bool)) (eqn : sided_pair expr) : tactic (option string) :=
do i ← try_mk_search_instance cfg rs eqn,
   match i with
   | none := return none
   | some i := do (i, result) ← i.search_until_solved,
                  match result with
                  | search_result.failure reason :=
                    tactic.fail reason
                  | search_result.success proof steps :=
                    tactic.exact proof >> some <$> i.explain proof steps
                  end

end

end tactic.rewrite_search
