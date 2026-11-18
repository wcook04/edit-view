/-!
# The reconstruction behind the edit view

Texts are lists of characters (any type works). The view cuts each text into an opening
of length `p`, a middle, and an ending of length `s`.

* `cut_join`: the three pieces of a text join back into the text.
* `view_decodes`: if the old and new text agree on their first `p` and last `s`
  characters, the four pieces shown (shared opening, removed middle, added middle, shared
  ending) rebuild both texts.
* `view_injective`: two edits shown as the same four pieces are the same edit.

These are the list facts behind `split` and `unpack` in `edit_view.py`. Lean checks the
statements about lists; it does not check the Python. The Python closes that gap at run
time: `project` rebuilds both edit arguments from the line it is about to return and
compares them with the real ones.
-/

namespace EditView

variable {α : Type}

/-- The middle of a text once `p` opening and `s` closing characters are set aside. -/
def middle (xs : List α) (p s : Nat) : List α :=
  (xs.drop p).take (xs.length - p - s)

/-- The last `s` characters of a text. -/
def ending (xs : List α) (s : Nat) : List α :=
  xs.drop (xs.length - s)

/-- Opening, middle and ending join back into the text. -/
theorem cut_join (xs : List α) (p s : Nat) (h : p + s ≤ xs.length) :
    xs.take p ++ middle xs p s ++ ending xs s = xs := by
  have e : ending xs s = (xs.drop p).drop (xs.length - p - s) := by
    simp only [ending, List.drop_drop]
    congr 1
    omega
  rw [List.append_assoc, e, middle, List.take_append_drop, List.take_append_drop]

/-- What the monitor is shown. -/
structure View (α : Type) where
  unchangedBefore : List α
  removes : List α
  adds : List α
  unchangedAfter : List α

/-- The edit arguments a view stands for. -/
def decode (v : View α) : List α × List α :=
  (v.unchangedBefore ++ v.removes ++ v.unchangedAfter,
   v.unchangedBefore ++ v.adds ++ v.unchangedAfter)

/-- The view of the edit from `old` to `new`, cut at `p` and `s`. -/
def view (old new : List α) (p s : Nat) : View α :=
  ⟨old.take p, middle old p s, middle new p s, ending old s⟩

/-- When the texts agree on the opening and ending, the view rebuilds both. -/
theorem view_decodes (old new : List α) (p s : Nat)
    (ho : p + s ≤ old.length) (hn : p + s ≤ new.length)
    (hp : old.take p = new.take p) (hs : ending old s = ending new s) :
    decode (view old new p s) = (old, new) := by
  show (old.take p ++ middle old p s ++ ending old s,
        old.take p ++ middle new p s ++ ending old s) = (old, new)
  rw [cut_join old p s ho, hp, hs, cut_join new p s hn]

/-- Two edits with the same view are the same edit. -/
theorem view_injective {old new old' new' : List α} {p s p' s' : Nat}
    (ho : p + s ≤ old.length) (hn : p + s ≤ new.length)
    (hp : old.take p = new.take p) (hs : ending old s = ending new s)
    (ho' : p' + s' ≤ old'.length) (hn' : p' + s' ≤ new'.length)
    (hp' : old'.take p' = new'.take p') (hs' : ending old' s' = ending new' s')
    (h : view old new p s = view old' new' p' s') :
    old = old' ∧ new = new' := by
  have e := congrArg decode h
  rw [view_decodes old new p s ho hn hp hs, view_decodes old' new' p' s' ho' hn' hp' hs'] at e
  exact ⟨congrArg Prod.fst e, congrArg Prod.snd e⟩

end EditView
