/-
Copyright (c) 2016 Jeremy Avigad. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jeremy Avigad, Leonardo de Moura, Mario Carneiro, Johannes Hölzl
-/
import algebra.ordered_monoid

set_option old_structure_cmd true

/-!
# Ordered groups

This file develops the basics of ordered groups.

## Implementation details

Unfortunately, the number of `'` appended to lemmas in this file
may differ between the multiplicative and the additive version of a lemma.
The reason is that we did not want to change existing names in the library.

-/

universe u
variable {α : Type u}

/-- An ordered additive commutative group is an additive commutative group
with a partial order in which addition is strictly monotone. -/
@[protect_proj, ancestor add_comm_group partial_order]
class ordered_add_comm_group (α : Type u) extends add_comm_group α, partial_order α :=
(add_le_add_left : ∀ a b : α, a ≤ b → ∀ c : α, c + a ≤ c + b)

/-- An ordered commutative group is an commutative group
with a partial order in which multiplication is strictly monotone. -/
@[protect_proj, ancestor comm_group partial_order]
class ordered_comm_group (α : Type u) extends comm_group α, partial_order α :=
(mul_le_mul_left : ∀ a b : α, a ≤ b → ∀ c : α, c * a ≤ c * b)

attribute [to_additive] ordered_comm_group

/--The units of an ordered commutative monoid form an ordered commutative group. -/
@[to_additive]
instance units.ordered_comm_group [ordered_comm_monoid α] : ordered_comm_group (units α) :=
{ mul_le_mul_left := λ a b h c, mul_le_mul_left' h _,
  .. units.partial_order,
  .. (infer_instance : comm_group (units α)) }

section ordered_comm_group
variables [ordered_comm_group α] {a b c d : α}

@[to_additive ordered_add_comm_group.add_lt_add_left]
lemma ordered_comm_group.mul_lt_mul_left' (a b : α) (h : a < b) (c : α) : c * a < c * b :=
begin
  rw lt_iff_le_not_le at h ⊢,
  split,
  { apply ordered_comm_group.mul_le_mul_left _ _ h.1 },
  { intro w,
    replace w : c⁻¹ * (c * b) ≤ c⁻¹ * (c * a) := ordered_comm_group.mul_le_mul_left _ _ w _,
    simp only [mul_one, mul_comm, mul_left_inv, mul_left_comm] at w,
    exact h.2 w },
end

@[to_additive ordered_add_comm_group.le_of_add_le_add_left]
lemma ordered_comm_group.le_of_mul_le_mul_left (h : a * b ≤ a * c) : b ≤ c :=
have a⁻¹ * (a * b) ≤ a⁻¹ * (a * c), from ordered_comm_group.mul_le_mul_left _ _ h _,
begin simp [inv_mul_cancel_left] at this, assumption end

@[to_additive]
lemma ordered_comm_group.lt_of_mul_lt_mul_left (h : a * b < a * c) : b < c :=
have a⁻¹ * (a * b) < a⁻¹ * (a * c), from ordered_comm_group.mul_lt_mul_left' _ _ h _,
begin simp [inv_mul_cancel_left] at this, assumption end

@[priority 100, to_additive]    -- see Note [lower instance priority]
instance ordered_comm_group.to_ordered_cancel_comm_monoid (α : Type u)
  [s : ordered_comm_group α] : ordered_cancel_comm_monoid α :=
{ mul_left_cancel       := @mul_left_cancel α _,
  mul_right_cancel      := @mul_right_cancel α _,
  le_of_mul_le_mul_left := @ordered_comm_group.le_of_mul_le_mul_left α _,
  ..s }

@[to_additive neg_le_neg]
lemma inv_le_inv' (h : a ≤ b) : b⁻¹ ≤ a⁻¹ :=
have 1 ≤ a⁻¹ * b,           from mul_left_inv a ▸ mul_le_mul_left' h _,
have 1 * b⁻¹ ≤ a⁻¹ * b * b⁻¹, from mul_le_mul_right' this _,
by rwa [mul_inv_cancel_right, one_mul] at this

@[to_additive]
lemma le_of_inv_le_inv (h : b⁻¹ ≤ a⁻¹) : a ≤ b :=
suffices (a⁻¹)⁻¹ ≤ (b⁻¹)⁻¹, from
  begin simp [inv_inv] at this, assumption end,
inv_le_inv' h

@[to_additive]
lemma one_le_of_inv_le_one (h : a⁻¹ ≤ 1) : 1 ≤ a :=
have a⁻¹ ≤ 1⁻¹, by rwa one_inv,
le_of_inv_le_inv this

@[to_additive]
lemma inv_le_one_of_one_le (h : 1 ≤ a) : a⁻¹ ≤ 1 :=
have a⁻¹ ≤ 1⁻¹, from inv_le_inv' h,
by rwa one_inv at this

@[to_additive nonpos_of_neg_nonneg]
lemma le_one_of_one_le_inv (h : 1 ≤ a⁻¹) : a ≤ 1 :=
have 1⁻¹ ≤ a⁻¹, by rwa one_inv,
le_of_inv_le_inv this

@[to_additive neg_nonneg_of_nonpos]
lemma one_le_inv_of_le_one (h : a ≤ 1) : 1 ≤ a⁻¹ :=
have 1⁻¹ ≤ a⁻¹, from inv_le_inv' h,
by rwa one_inv at this

@[to_additive neg_lt_neg]
lemma inv_lt_inv' (h : a < b) : b⁻¹ < a⁻¹ :=
have 1 < a⁻¹ * b, from mul_left_inv a ▸ mul_lt_mul_left' h (a⁻¹),
have 1 * b⁻¹ < a⁻¹ * b * b⁻¹, from mul_lt_mul_right' this (b⁻¹),
by rwa [mul_inv_cancel_right, one_mul] at this

@[to_additive]
lemma lt_of_inv_lt_inv (h : b⁻¹ < a⁻¹) : a < b :=
inv_inv a ▸ inv_inv b ▸ inv_lt_inv' h

@[to_additive]
lemma one_lt_of_inv_inv (h : a⁻¹ < 1) : 1 < a :=
have a⁻¹ < 1⁻¹, by rwa one_inv,
lt_of_inv_lt_inv this

@[to_additive]
lemma inv_inv_of_one_lt (h : 1 < a) : a⁻¹ < 1 :=
have a⁻¹ < 1⁻¹, from inv_lt_inv' h,
by rwa one_inv at this

@[to_additive neg_of_neg_pos]
lemma inv_of_one_lt_inv (h : 1 < a⁻¹) : a < 1 :=
have 1⁻¹ < a⁻¹, by rwa one_inv,
lt_of_inv_lt_inv this

@[to_additive neg_pos_of_neg]
lemma one_lt_inv_of_inv (h : a < 1) : 1 < a⁻¹ :=
have 1⁻¹ < a⁻¹, from inv_lt_inv' h,
by rwa one_inv at this

@[to_additive]
lemma le_inv_of_le_inv (h : a ≤ b⁻¹) : b ≤ a⁻¹ :=
begin
  have h := inv_le_inv' h,
  rwa inv_inv at h
end

@[to_additive]
lemma inv_le_of_inv_le (h : a⁻¹ ≤ b) : b⁻¹ ≤ a :=
begin
  have h := inv_le_inv' h,
  rwa inv_inv at h
end

@[to_additive]
lemma lt_inv_of_lt_inv (h : a < b⁻¹) : b < a⁻¹ :=
begin
  have h := inv_lt_inv' h,
  rwa inv_inv at h
end

@[to_additive]
lemma inv_lt_of_inv_lt (h : a⁻¹ < b) : b⁻¹ < a :=
begin
  have h := inv_lt_inv' h,
  rwa inv_inv at h
end

@[to_additive]
lemma mul_le_of_le_inv_mul (h : b ≤ a⁻¹ * c) : a * b ≤ c :=
begin
  have h := mul_le_mul_left' h a,
  rwa mul_inv_cancel_left at h
end

@[to_additive]
lemma le_inv_mul_of_mul_le (h : a * b ≤ c) : b ≤ a⁻¹ * c :=
begin
  have h := mul_le_mul_left' h a⁻¹,
  rwa inv_mul_cancel_left at h
end

@[to_additive]
lemma le_mul_of_inv_mul_le (h : b⁻¹ * a ≤ c) : a ≤ b * c :=
begin
  have h := mul_le_mul_left' h b,
  rwa mul_inv_cancel_left at h
end

@[to_additive]
lemma inv_mul_le_of_le_mul (h : a ≤ b * c) : b⁻¹ * a ≤ c :=
begin
  have h := mul_le_mul_left' h b⁻¹,
  rwa inv_mul_cancel_left at h
end

@[to_additive]
lemma le_mul_of_inv_mul_le_left (h : b⁻¹ * a ≤ c) : a ≤ b * c :=
le_mul_of_inv_mul_le h

@[to_additive]
lemma inv_mul_le_left_of_le_mul (h : a ≤ b * c) : b⁻¹ * a ≤ c :=
inv_mul_le_of_le_mul h

@[to_additive]
lemma le_mul_of_inv_mul_le_right (h : c⁻¹ * a ≤ b) : a ≤ b * c :=
by { rw mul_comm, exact le_mul_of_inv_mul_le h }

@[to_additive]
lemma inv_mul_le_right_of_le_mul (h : a ≤ b * c) : c⁻¹ * a ≤ b :=
by { rw mul_comm at h, apply inv_mul_le_left_of_le_mul h }

@[to_additive]
lemma mul_lt_of_lt_inv_mul (h : b < a⁻¹ * c) : a * b < c :=
begin
  have h := mul_lt_mul_left' h a,
  rwa mul_inv_cancel_left at h
end

@[to_additive]
lemma lt_inv_mul_of_mul_lt (h : a * b < c) : b < a⁻¹ * c :=
begin
  have h := mul_lt_mul_left' h (a⁻¹),
  rwa inv_mul_cancel_left at h
end

@[to_additive]
lemma lt_mul_of_inv_mul_lt (h : b⁻¹ * a < c) : a < b * c :=
begin
  have h := mul_lt_mul_left' h b,
  rwa mul_inv_cancel_left at h
end

@[to_additive]
lemma inv_mul_lt_of_lt_mul (h : a < b * c) : b⁻¹ * a < c :=
begin
  have h := mul_lt_mul_left' h (b⁻¹),
  rwa inv_mul_cancel_left at h
end

@[to_additive]
lemma lt_mul_of_inv_mul_lt_left (h : b⁻¹ * a < c) : a < b * c :=
lt_mul_of_inv_mul_lt h

@[to_additive]
lemma inv_mul_lt_left_of_lt_mul (h : a < b * c) : b⁻¹ * a < c :=
inv_mul_lt_of_lt_mul h

@[to_additive]
lemma lt_mul_of_inv_mul_lt_right (h : c⁻¹ * a < b) : a < b * c :=
by { rw mul_comm, exact lt_mul_of_inv_mul_lt h }

@[to_additive]
lemma inv_mul_lt_right_of_lt_mul (h : a < b * c) : c⁻¹ * a < b :=
by { rw mul_comm at h, exact inv_mul_lt_of_lt_mul h }

@[simp, to_additive]
lemma inv_lt_one_iff_one_lt : a⁻¹ < 1 ↔ 1 < a :=
⟨ one_lt_of_inv_inv, inv_inv_of_one_lt ⟩

@[simp, to_additive]
lemma inv_le_inv_iff : a⁻¹ ≤ b⁻¹ ↔ b ≤ a :=
have a * b * a⁻¹ ≤ a * b * b⁻¹ ↔ a⁻¹ ≤ b⁻¹, from mul_le_mul_iff_left _,
by { rw [mul_inv_cancel_right, mul_comm a, mul_inv_cancel_right] at this, rw [this] }

@[to_additive neg_le]
lemma inv_le' : a⁻¹ ≤ b ↔ b⁻¹ ≤ a :=
have a⁻¹ ≤ (b⁻¹)⁻¹ ↔ b⁻¹ ≤ a, from inv_le_inv_iff,
by rwa inv_inv at this

@[to_additive le_neg]
lemma le_inv' : a ≤ b⁻¹ ↔ b ≤ a⁻¹ :=
have (a⁻¹)⁻¹ ≤ b⁻¹ ↔ b ≤ a⁻¹, from inv_le_inv_iff,
by rwa inv_inv at this

@[to_additive neg_le_iff_add_nonneg]
lemma inv_le_iff_one_le_mul : a⁻¹ ≤ b ↔ 1 ≤ a * b :=
(mul_le_mul_iff_left a).symm.trans $ by rw mul_inv_self

@[to_additive]
lemma le_inv_iff_mul_le_one : a ≤ b⁻¹ ↔ a * b ≤ 1 :=
(mul_le_mul_iff_right b).symm.trans $ by rw inv_mul_self

@[simp, to_additive neg_nonpos]
lemma inv_le_one' : a⁻¹ ≤ 1 ↔ 1 ≤ a :=
have a⁻¹ ≤ 1⁻¹ ↔ 1 ≤ a, from inv_le_inv_iff,
by rwa one_inv at this

@[simp, to_additive neg_nonneg]
lemma one_le_inv' : 1 ≤ a⁻¹ ↔ a ≤ 1 :=
have 1⁻¹ ≤ a⁻¹ ↔ a ≤ 1, from inv_le_inv_iff,
by rwa one_inv at this

@[to_additive]
lemma inv_le_self (h : 1 ≤ a) : a⁻¹ ≤ a :=
le_trans (inv_le_one'.2 h) h

@[to_additive]
lemma self_le_inv (h : a ≤ 1) : a ≤ a⁻¹ :=
le_trans h (one_le_inv'.2 h)

@[simp, to_additive]
lemma inv_lt_inv_iff : a⁻¹ < b⁻¹ ↔ b < a :=
have a * b * a⁻¹ < a * b * b⁻¹ ↔ a⁻¹ < b⁻¹, from mul_lt_mul_iff_left _,
by { rw [mul_inv_cancel_right, mul_comm a, mul_inv_cancel_right] at this, rw [this] }

@[to_additive neg_lt_zero]
lemma inv_lt_one' : a⁻¹ < 1 ↔ 1 < a :=
have a⁻¹ < 1⁻¹ ↔ 1 < a, from inv_lt_inv_iff,
by rwa one_inv at this

@[to_additive neg_pos]
lemma one_lt_inv' : 1 < a⁻¹ ↔ a < 1 :=
have 1⁻¹ < a⁻¹ ↔ a < 1, from inv_lt_inv_iff,
by rwa one_inv at this

@[to_additive neg_lt]
lemma inv_lt' : a⁻¹ < b ↔ b⁻¹ < a :=
have a⁻¹ < (b⁻¹)⁻¹ ↔ b⁻¹ < a, from inv_lt_inv_iff,
by rwa inv_inv at this

@[to_additive lt_neg]
lemma lt_inv' : a < b⁻¹ ↔ b < a⁻¹ :=
have (a⁻¹)⁻¹ < b⁻¹ ↔ b < a⁻¹, from inv_lt_inv_iff,
by rwa inv_inv at this

@[to_additive]
lemma le_inv_mul_iff_mul_le : b ≤ a⁻¹ * c ↔ a * b ≤ c :=
have a⁻¹ * (a * b) ≤ a⁻¹ * c ↔ a * b ≤ c, from mul_le_mul_iff_left _,
by rwa inv_mul_cancel_left at this

@[simp, to_additive]
lemma inv_mul_le_iff_le_mul : b⁻¹ * a ≤ c ↔ a ≤ b * c :=
have b⁻¹ * a ≤ b⁻¹ * (b * c) ↔ a ≤ b * c, from mul_le_mul_iff_left _,
by rwa inv_mul_cancel_left at this

@[to_additive]
lemma mul_inv_le_iff_le_mul : a * c⁻¹ ≤ b ↔ a ≤ b * c :=
by rw [mul_comm a, mul_comm b, inv_mul_le_iff_le_mul]

@[simp, to_additive]
lemma mul_inv_le_iff_le_mul' : a * b⁻¹ ≤ c ↔ a ≤ b * c :=
by rw [← inv_mul_le_iff_le_mul, mul_comm]

@[to_additive]
lemma inv_mul_le_iff_le_mul' : c⁻¹ * a ≤ b ↔ a ≤ b * c :=
by rw [inv_mul_le_iff_le_mul, mul_comm]

@[simp, to_additive]
lemma lt_inv_mul_iff_mul_lt : b < a⁻¹ * c ↔ a * b < c :=
have a⁻¹ * (a * b) < a⁻¹ * c ↔ a * b < c, from mul_lt_mul_iff_left _,
by rwa inv_mul_cancel_left at this

@[simp, to_additive]
lemma inv_mul_lt_iff_lt_mul : b⁻¹ * a < c ↔ a < b * c :=
have b⁻¹ * a < b⁻¹ * (b * c) ↔ a < b * c, from mul_lt_mul_iff_left _,
by rwa inv_mul_cancel_left at this

@[to_additive]
lemma inv_mul_lt_iff_lt_mul_right : c⁻¹ * a < b ↔ a < b * c :=
by rw [inv_mul_lt_iff_lt_mul, mul_comm]

@[to_additive add_neg_le_add_neg_iff]
lemma div_le_div_iff' : a * b⁻¹ ≤ c * d⁻¹ ↔ a * d ≤ c * b :=
begin
  split ; intro h,
  have := mul_le_mul_right' (mul_le_mul_right' h b) d,
  rwa [inv_mul_cancel_right, mul_assoc _ _ b, mul_comm _ b, ← mul_assoc, inv_mul_cancel_right] at this,
  have := mul_le_mul_right' (mul_le_mul_right' h d⁻¹) b⁻¹,
  rwa [mul_inv_cancel_right, _root_.mul_assoc, _root_.mul_comm d⁻¹ b⁻¹, ← mul_assoc, mul_inv_cancel_right] at this,
end

end ordered_comm_group

section ordered_add_comm_group
variables [ordered_add_comm_group α] {a b c d : α}

lemma sub_nonneg_of_le (h : b ≤ a) : 0 ≤ a - b :=
begin
  have h := add_le_add_right h (-b),
  rwa [add_right_neg, ← sub_eq_add_neg] at h
end

lemma le_of_sub_nonneg (h : 0 ≤ a - b) : b ≤ a :=
begin
  have h := add_le_add_right h b,
  rwa [sub_add_cancel, zero_add] at h
end

lemma sub_nonpos_of_le (h : a ≤ b) : a - b ≤ 0 :=
begin
  have h := add_le_add_right h (-b),
  rwa [add_right_neg, ← sub_eq_add_neg] at h
end

lemma le_of_sub_nonpos (h : a - b ≤ 0) : a ≤ b :=
begin
  have h := add_le_add_right h b,
  rwa [sub_add_cancel, zero_add] at h
end

lemma sub_pos_of_lt (h : b < a) : 0 < a - b :=
begin
  have h := add_lt_add_right h (-b),
  rwa [add_right_neg, ← sub_eq_add_neg] at h
end

lemma lt_of_sub_pos (h : 0 < a - b) : b < a :=
begin
  have h := add_lt_add_right h b,
  rwa [sub_add_cancel, zero_add] at h
end

lemma sub_neg_of_lt (h : a < b) : a - b < 0 :=
begin
  have h := add_lt_add_right h (-b),
  rwa [add_right_neg, ← sub_eq_add_neg] at h
end

lemma lt_of_sub_neg (h : a - b < 0) : a < b :=
begin
  have h := add_lt_add_right h b,
  rwa [sub_add_cancel, zero_add] at h
end

lemma add_le_of_le_sub_left (h : b ≤ c - a) : a + b ≤ c :=
begin
  have h := add_le_add_left h a,
  rwa [← add_sub_assoc, add_comm a c, add_sub_cancel] at h
end

lemma le_sub_left_of_add_le (h : a + b ≤ c) : b ≤ c - a :=
begin
  have h := add_le_add_right h (-a),
  rwa [add_comm a b, add_neg_cancel_right, ← sub_eq_add_neg] at h
end

lemma add_le_of_le_sub_right (h : a ≤ c - b) : a + b ≤ c :=
begin
  have h := add_le_add_right h b,
  rwa sub_add_cancel at h
end

lemma le_sub_right_of_add_le (h : a + b ≤ c) : a ≤ c - b :=
begin
  have h := add_le_add_right h (-b),
  rwa [add_neg_cancel_right, ← sub_eq_add_neg] at h
end

lemma le_add_of_sub_left_le (h : a - b ≤ c) : a ≤ b + c :=
begin
  have h := add_le_add_right h b,
  rwa [sub_add_cancel, add_comm] at h
end

lemma sub_left_le_of_le_add (h : a ≤ b + c) : a - b ≤ c :=
begin
  have h := add_le_add_right h (-b),
  rwa [add_comm b c, add_neg_cancel_right, ← sub_eq_add_neg] at h
end

lemma le_add_of_sub_right_le (h : a - c ≤ b) : a ≤ b + c :=
begin
  have h := add_le_add_right h c,
  rwa sub_add_cancel at h
end

lemma sub_right_le_of_le_add (h : a ≤ b + c) : a - c ≤ b :=
begin
  have h := add_le_add_right h (-c),
  rwa [add_neg_cancel_right, ← sub_eq_add_neg] at h
end

lemma le_add_of_neg_le_sub_left (h : -a ≤ b - c) : c ≤ a + b :=
le_add_of_neg_add_le_left (add_le_of_le_sub_right h)

lemma neg_le_sub_left_of_le_add (h : c ≤ a + b) : -a ≤ b - c :=
begin
  rw [sub_eq_add_neg, add_comm],
  apply le_neg_add_of_add_le,
  have h := (sub_left_le_of_le_add h),
  rwa sub_eq_add_neg at h
end

lemma le_add_of_neg_le_sub_right (h : -b ≤ a - c) : c ≤ a + b :=
begin
  have h := add_le_of_le_sub_left h,
  rw ← sub_eq_add_neg at h,
  exact le_add_of_sub_right_le h
end

lemma neg_le_sub_right_of_le_add (h : c ≤ a + b) : -b ≤ a - c :=
begin
  have h := sub_right_le_of_le_add h,
  rw sub_eq_add_neg at h,
  exact le_sub_left_of_add_le h
end

lemma sub_le_of_sub_le (h : a - b ≤ c) : a - c ≤ b :=
sub_left_le_of_le_add (le_add_of_sub_right_le h)

lemma sub_le_sub_left (h : a ≤ b) (c : α) : c - b ≤ c - a :=
by simpa only [sub_eq_add_neg] using add_le_add_left (neg_le_neg h) c

lemma sub_le_sub_right (h : a ≤ b) (c : α) : a - c ≤ b - c :=
by simpa only [sub_eq_add_neg] using add_le_add_right h (-c)

lemma sub_le_sub (hab : a ≤ b) (hcd : c ≤ d) : a - d ≤ b - c :=
by simpa only [sub_eq_add_neg] using add_le_add hab (neg_le_neg hcd)

lemma add_lt_of_lt_sub_left (h : b < c - a) : a + b < c :=
begin
  have h := add_lt_add_left h a,
  rwa [← add_sub_assoc, add_comm a c, add_sub_cancel] at h
end

lemma lt_sub_left_of_add_lt (h : a + b < c) : b < c - a :=
begin
  have h := add_lt_add_right h (-a),
  rwa [add_comm a b, add_neg_cancel_right, ← sub_eq_add_neg] at h
end

lemma add_lt_of_lt_sub_right (h : a < c - b) : a + b < c :=
begin
  have h := add_lt_add_right h b,
  rwa sub_add_cancel at h
end

lemma lt_sub_right_of_add_lt (h : a + b < c) : a < c - b :=
begin
  have h := add_lt_add_right h (-b),
  rwa [add_neg_cancel_right, ← sub_eq_add_neg] at h
end

lemma lt_add_of_sub_left_lt (h : a - b < c) : a < b + c :=
begin
  have h := add_lt_add_right h b,
  rwa [sub_add_cancel, add_comm] at h
end

lemma sub_left_lt_of_lt_add (h : a < b + c) : a - b < c :=
begin
  have h := add_lt_add_right h (-b),
  rwa [add_comm b c, add_neg_cancel_right, ← sub_eq_add_neg] at h
end

lemma lt_add_of_sub_right_lt (h : a - c < b) : a < b + c :=
begin
  have h := add_lt_add_right h c,
  rwa sub_add_cancel at h
end

lemma sub_right_lt_of_lt_add (h : a < b + c) : a - c < b :=
begin
  have h := add_lt_add_right h (-c),
  rwa [add_neg_cancel_right, ← sub_eq_add_neg] at h
end

lemma lt_add_of_neg_lt_sub_left (h : -a < b - c) : c < a + b :=
lt_add_of_neg_add_lt_left (add_lt_of_lt_sub_right h)

lemma neg_lt_sub_left_of_lt_add (h : c < a + b) : -a < b - c :=
begin
  have h := sub_left_lt_of_lt_add h,
  rw sub_eq_add_neg at h,
  have h := lt_neg_add_of_add_lt h,
  rwa [add_comm, ← sub_eq_add_neg] at h
end

lemma lt_add_of_neg_lt_sub_right (h : -b < a - c) : c < a + b :=
begin
  have h := add_lt_of_lt_sub_left h,
  rw ← sub_eq_add_neg at h,
  exact lt_add_of_sub_right_lt h
end

lemma neg_lt_sub_right_of_lt_add (h : c < a + b) : -b < a - c :=
begin
  have h := sub_right_lt_of_lt_add h,
  rw sub_eq_add_neg at h,
  exact lt_sub_left_of_add_lt h
end

lemma sub_lt_of_sub_lt (h : a - b < c) : a - c < b :=
sub_left_lt_of_lt_add (lt_add_of_sub_right_lt h)

lemma sub_lt_sub_left (h : a < b) (c : α) : c - b < c - a :=
by simpa only [sub_eq_add_neg] using add_lt_add_left (neg_lt_neg h) c

lemma sub_lt_sub_right (h : a < b) (c : α) : a - c < b - c :=
by simpa only [sub_eq_add_neg] using add_lt_add_right h (-c)

lemma sub_lt_sub (hab : a < b) (hcd : c < d) : a - d < b - c :=
by simpa only [sub_eq_add_neg] using add_lt_add hab (neg_lt_neg hcd)

lemma sub_lt_sub_of_le_of_lt (hab : a ≤ b) (hcd : c < d) : a - d < b - c :=
by simpa only [sub_eq_add_neg] using add_lt_add_of_le_of_lt hab (neg_lt_neg hcd)

lemma sub_lt_sub_of_lt_of_le (hab : a < b) (hcd : c ≤ d) : a - d < b - c :=
by simpa only [sub_eq_add_neg] using add_lt_add_of_lt_of_le hab (neg_le_neg hcd)

lemma sub_le_self (a : α) {b : α} (h : 0 ≤ b) : a - b ≤ a :=
calc
  a - b = a + -b : sub_eq_add_neg _ _
    ... ≤ a + 0  : add_le_add_left (neg_nonpos_of_nonneg h) _
    ... = a      : by rw add_zero

lemma sub_lt_self (a : α) {b : α} (h : 0 < b) : a - b < a :=
calc
  a - b = a + -b : sub_eq_add_neg _ _
    ... < a + 0  : add_lt_add_left (neg_neg_of_pos h) _
    ... = a      : by rw add_zero

lemma sub_le_sub_iff : a - b ≤ c - d ↔ a + d ≤ c + b :=
by simpa only [sub_eq_add_neg] using add_neg_le_add_neg_iff

@[simp]
lemma sub_le_sub_iff_left (a : α) {b c : α} : a - b ≤ a - c ↔ c ≤ b :=
by rw [sub_eq_add_neg, sub_eq_add_neg, add_le_add_iff_left, neg_le_neg_iff]

@[simp]
lemma sub_le_sub_iff_right (c : α) : a - c ≤ b - c ↔ a ≤ b :=
by simpa only [sub_eq_add_neg] using add_le_add_iff_right _

@[simp]
lemma sub_lt_sub_iff_left (a : α) {b c : α} : a - b < a - c ↔ c < b :=
by rw [sub_eq_add_neg, sub_eq_add_neg, add_lt_add_iff_left, neg_lt_neg_iff]

@[simp]
lemma sub_lt_sub_iff_right (c : α) : a - c < b - c ↔ a < b :=
by simpa only [sub_eq_add_neg] using add_lt_add_iff_right _

@[simp] lemma sub_nonneg : 0 ≤ a - b ↔ b ≤ a :=
have a - a ≤ a - b ↔ b ≤ a, from sub_le_sub_iff_left a,
by rwa sub_self at this

@[simp] lemma sub_nonpos : a - b ≤ 0 ↔ a ≤ b :=
have a - b ≤ b - b ↔ a ≤ b, from sub_le_sub_iff_right b,
by rwa sub_self at this

@[simp] lemma sub_pos : 0 < a - b ↔ b < a :=
have a - a < a - b ↔ b < a, from sub_lt_sub_iff_left a,
by rwa sub_self at this

@[simp] lemma sub_lt_zero : a - b < 0 ↔ a < b :=
have a - b < b - b ↔ a < b, from sub_lt_sub_iff_right b,
by rwa sub_self at this

lemma le_sub_iff_add_le' : b ≤ c - a ↔ a + b ≤ c :=
by rw [sub_eq_add_neg, add_comm, le_neg_add_iff_add_le]

lemma le_sub_iff_add_le : a ≤ c - b ↔ a + b ≤ c :=
by rw [le_sub_iff_add_le', add_comm]

lemma sub_le_iff_le_add' : a - b ≤ c ↔ a ≤ b + c :=
by rw [sub_eq_add_neg, add_comm, neg_add_le_iff_le_add]

lemma sub_le_iff_le_add : a - c ≤ b ↔ a ≤ b + c :=
by rw [sub_le_iff_le_add', add_comm]

@[simp] lemma neg_le_sub_iff_le_add : -b ≤ a - c ↔ c ≤ a + b :=
le_sub_iff_add_le.trans neg_add_le_iff_le_add'

lemma neg_le_sub_iff_le_add' : -a ≤ b - c ↔ c ≤ a + b :=
by rw [neg_le_sub_iff_le_add, add_comm]

lemma sub_le : a - b ≤ c ↔ a - c ≤ b :=
sub_le_iff_le_add'.trans sub_le_iff_le_add.symm

theorem le_sub : a ≤ b - c ↔ c ≤ b - a :=
le_sub_iff_add_le'.trans le_sub_iff_add_le.symm

lemma lt_sub_iff_add_lt' : b < c - a ↔ a + b < c :=
by rw [sub_eq_add_neg, add_comm, lt_neg_add_iff_add_lt]

lemma lt_sub_iff_add_lt : a < c - b ↔ a + b < c :=
by rw [lt_sub_iff_add_lt', add_comm]

lemma sub_lt_iff_lt_add' : a - b < c ↔ a < b + c :=
by rw [sub_eq_add_neg, add_comm, neg_add_lt_iff_lt_add]

lemma sub_lt_iff_lt_add : a - c < b ↔ a < b + c :=
by rw [sub_lt_iff_lt_add', add_comm]

@[simp] lemma neg_lt_sub_iff_lt_add : -b < a - c ↔ c < a + b :=
lt_sub_iff_add_lt.trans neg_add_lt_iff_lt_add_right

lemma neg_lt_sub_iff_lt_add' : -a < b - c ↔ c < a + b :=
by rw [neg_lt_sub_iff_lt_add, add_comm]

lemma sub_lt : a - b < c ↔ a - c < b :=
sub_lt_iff_lt_add'.trans sub_lt_iff_lt_add.symm

theorem lt_sub : a < b - c ↔ c < b - a :=
lt_sub_iff_add_lt'.trans lt_sub_iff_add_lt.symm

lemma sub_le_self_iff (a : α) {b : α} : a - b ≤ a ↔ 0 ≤ b :=
sub_le_iff_le_add'.trans (le_add_iff_nonneg_left _)

lemma sub_lt_self_iff (a : α) {b : α} : a - b < a ↔ 0 < b :=
sub_lt_iff_lt_add'.trans (lt_add_iff_pos_left _)

end ordered_add_comm_group

/-- A decidable linearly ordered additive commutative group is an
additive commutative group with a decidable linear order in which
addition is strictly monotone. -/
@[protect_proj] class linear_ordered_add_comm_group (α : Type u)
  extends add_comm_group α, linear_order α :=
(add_le_add_left : ∀ a b : α, a ≤ b → ∀ c : α, c + a ≤ c + b)

@[priority 100] -- see Note [lower instance priority]
instance linear_ordered_comm_group.to_ordered_add_comm_group (α : Type u)
  [s : linear_ordered_add_comm_group α] : ordered_add_comm_group α :=
{ add := s.add, ..s }

section linear_ordered_add_comm_group
variables [linear_ordered_add_comm_group α] {a b c : α}

@[priority 100] -- see Note [lower instance priority]
instance linear_ordered_add_comm_group.to_linear_ordered_cancel_add_comm_monoid :
  linear_ordered_cancel_add_comm_monoid α :=
{ le_of_add_le_add_left := λ x y z, le_of_add_le_add_left,
  add_left_cancel := λ x y z, add_left_cancel,
  add_right_cancel := λ x y z, add_right_cancel,
  ..‹linear_ordered_add_comm_group α› }

lemma linear_ordered_add_comm_group.add_lt_add_left
  (a b : α) (h : a < b) (c : α) : c + a < c + b :=
ordered_add_comm_group.add_lt_add_left a b h c

lemma min_neg_neg (a b : α) : min (-a) (-b) = -max a b :=
eq.symm $ @monotone.map_max α (order_dual α) _ _ has_neg.neg a b $ λ a b, neg_le_neg

lemma max_neg_neg (a b : α) : max (-a) (-b) = -min a b :=
eq.symm $ @monotone.map_min α (order_dual α) _ _ has_neg.neg a b $ λ a b, neg_le_neg

lemma min_sub_sub_right (a b c : α) : min (a - c) (b - c) = min a b - c :=
by simpa only [sub_eq_add_neg] using min_add_add_right a b (-c)

lemma max_sub_sub_right (a b c : α) : max (a - c) (b - c) = max a b - c :=
by simpa only [sub_eq_add_neg] using max_add_add_right a b (-c)

lemma min_sub_sub_left (a b c : α) : min (a - b) (a - c) = a - max b c :=
by simp only [sub_eq_add_neg, min_add_add_left, min_neg_neg]

lemma max_sub_sub_left (a b c : α) : max (a - b) (a - c) = a - min b c :=
by simp only [sub_eq_add_neg, max_add_add_left, max_neg_neg]

lemma max_zero_sub_eq_self (a : α) : max a 0 - max (-a) 0 = a :=
begin
  rcases le_total a 0,
  { rw [max_eq_right h, max_eq_left, zero_sub, neg_neg], { rwa [le_neg, neg_zero] } },
  { rw [max_eq_left, max_eq_right, sub_zero], { rwa [neg_le, neg_zero] }, exact h }
end

/-- `abs a` is the absolute value of `a`. -/
def abs (a : α) : α := max a (-a)

lemma abs_of_nonneg (h : 0 ≤ a) : abs a = a :=
max_eq_left $ (neg_nonpos.2 h).trans h

lemma abs_of_pos (h : 0 < a) : abs a = a :=
abs_of_nonneg h.le

lemma abs_of_nonpos (h : a ≤ 0) : abs a = -a :=
max_eq_right $ h.trans (neg_nonneg.2 h)

lemma abs_of_neg (h : a < 0) : abs a = -a :=
abs_of_nonpos h.le

@[simp] lemma abs_zero : abs 0 = (0:α) :=
abs_of_nonneg le_rfl

@[simp] lemma abs_neg (a : α) : abs (-a) = abs a :=
begin unfold abs, rw [max_comm, neg_neg] end

@[simp] lemma abs_pos : 0 < abs a ↔ a ≠ 0 :=
begin
  rcases lt_trichotomy a 0 with (ha|rfl|ha),
  { simp [abs_of_neg ha, neg_pos, ha.ne, ha] },
  { simp },
  { simp [abs_of_pos ha, ha, ha.ne.symm] }
end

lemma abs_pos_of_pos (h : 0 < a) : 0 < abs a := abs_pos.2 h.ne.symm

lemma abs_pos_of_neg (h : a < 0) : 0 < abs a := abs_pos.2 h.ne

lemma abs_sub (a b : α) : abs (a - b) = abs (b - a) :=
by rw [← neg_sub, abs_neg]

theorem abs_le' : abs a ≤ b ↔ a ≤ b ∧ -a ≤ b := max_le_iff

theorem abs_le : abs a ≤ b ↔ - b ≤ a ∧ a ≤ b :=
by rw [abs_le', and.comm, neg_le]

lemma le_abs_self (a : α) : a ≤ abs a := le_max_left _ _

lemma neg_le_abs_self (a : α) : -a ≤ abs a := le_max_right _ _

lemma abs_nonneg (a : α) : 0 ≤ abs a :=
(le_total 0 a).elim (λ h, h.trans (le_abs_self a)) (λ h, (neg_nonneg.2 h).trans $ neg_le_abs_self a)

@[simp] lemma abs_abs (a : α) : abs (abs a) = abs a :=
abs_of_nonneg $ abs_nonneg a

@[simp] lemma abs_eq_zero : abs a = 0 ↔ a = 0 :=
not_iff_not.1 $ ne_comm.trans $ (abs_nonneg a).lt_iff_ne.symm.trans abs_pos

@[simp] lemma abs_nonpos_iff {a : α} : abs a ≤ 0 ↔ a = 0 :=
(abs_nonneg a).le_iff_eq.trans abs_eq_zero

lemma abs_lt {a b : α} : abs a < b ↔ - b < a ∧ a < b :=
max_lt_iff.trans $ and.comm.trans $ by rw [neg_lt]

lemma lt_abs {a b : α} : a < abs b ↔ a < b ∨ a < -b := lt_max_iff

lemma max_sub_min_eq_abs' (a b : α) : max a b - min a b = abs (a - b) :=
begin
  cases le_total a b with ab ba,
  { rw [max_eq_right ab, min_eq_left ab, abs_of_nonpos, neg_sub], rwa sub_nonpos },
  { rw [max_eq_left ba, min_eq_right ba, abs_of_nonneg], exact sub_nonneg_of_le ba }
end

lemma max_sub_min_eq_abs (a b : α) : max a b - min a b = abs (b - a) :=
by { rw [abs_sub], exact max_sub_min_eq_abs' _ _ }

lemma abs_add (a b : α) : abs (a + b) ≤ abs a + abs b :=
abs_le.2 ⟨(neg_add (abs a) (abs b)).symm ▸
  add_le_add (neg_le.2 $ neg_le_abs_self _) (neg_le.2 $ neg_le_abs_self _),
  add_le_add (le_abs_self _) (le_abs_self _)⟩

lemma abs_sub_le_iff : abs (a - b) ≤ c ↔ a - b ≤ c ∧ b - a ≤ c :=
by rw [abs_le, neg_le_sub_iff_le_add, @sub_le_iff_le_add' _ _ b, and_comm]

lemma abs_sub_lt_iff : abs (a - b) < c ↔ a - b < c ∧ b - a < c :=
by rw [abs_lt, neg_lt_sub_iff_lt_add, @sub_lt_iff_lt_add' _ _ b, and_comm]

lemma abs_sub_abs_le_abs_sub (a b : α) : abs a - abs b ≤ abs (a - b) :=
sub_le_iff_le_add.2 $
calc abs a = abs (a - b + b)     : by rw [sub_add_cancel]
       ... ≤ abs (a - b) + abs b : abs_add _ _

lemma abs_abs_sub_abs_le_abs_sub (a b : α) : abs (abs a - abs b) ≤ abs (a - b) :=
abs_sub_le_iff.2 ⟨abs_sub_abs_le_abs_sub _ _, by rw abs_sub; apply abs_sub_abs_le_abs_sub⟩

lemma abs_eq (hb : 0 ≤ b) : abs a = b ↔ a = b ∨ a = -b :=
iff.intro
  begin
    cases le_total a 0 with a_nonpos a_nonneg,
    { rw [abs_of_nonpos a_nonpos, neg_eq_iff_neg_eq, eq_comm], exact or.inr },
    { rw [abs_of_nonneg a_nonneg, eq_comm], exact or.inl }
  end
  (by intro h; cases h; subst h; try { rw abs_neg }; exact abs_of_nonneg hb)

lemma abs_le_max_abs_abs (hab : a ≤ b)  (hbc : b ≤ c) : abs b ≤ max (abs a) (abs c) :=
abs_le'.2
  ⟨by simp [hbc.trans (le_abs_self c)],
   by simp [(neg_le_neg hab).trans (neg_le_abs_self a)]⟩

theorem abs_le_abs (h₀ : a ≤ b) (h₁ : -a ≤ b) : abs a ≤ abs b :=
(abs_le'.2 ⟨h₀, h₁⟩).trans (le_abs_self b)

lemma abs_max_sub_max_le_abs (a b c : α) : abs (max a c - max b c) ≤ abs (a - b) :=
begin
  simp_rw [abs_le, le_sub_iff_add_le, sub_le_iff_le_add, ← max_add_add_left],
  split; apply max_le_max; simp only [← le_sub_iff_add_le, ← sub_le_iff_le_add, sub_self, neg_le,
    neg_le_abs_self, neg_zero, abs_nonneg, le_abs_self]
end

lemma eq_zero_of_neg_eq {a : α} (h : -a = a) : a = 0 :=
match lt_trichotomy a 0 with
| or.inl h₁ :=
  have 0 < a, from h ▸ neg_pos_of_neg h₁,
  absurd h₁ this.asymm
| or.inr (or.inl h₁) := h₁
| or.inr (or.inr h₁) :=
  have a < 0, from h ▸ neg_neg_of_pos h₁,
  absurd h₁ this.asymm
end

lemma eq_of_abs_sub_eq_zero {a b : α} (h : abs (a - b) = 0) : a = b :=
sub_eq_zero.1 $ abs_eq_zero.1 h

lemma abs_by_cases (P : α → Prop) {a : α} (h1 : P a) (h2 : P (-a)) : P (abs a) :=
sup_ind _ _ h1 h2

lemma abs_sub_le (a b c : α) : abs (a - c) ≤ abs (a - b) + abs (b - c) :=
calc
    abs (a - c) = abs (a - b + (b - c))     : by rw [sub_add_sub_cancel]
            ... ≤ abs (a - b) + abs (b - c) : abs_add _ _

lemma abs_add_three (a b c : α) : abs (a + b + c) ≤ abs a + abs b + abs c :=
(abs_add _ _).trans (add_le_add_right (abs_add _ _) _)

lemma dist_bdd_within_interval {a b lb ub : α} (hal : lb ≤ a) (hau : a ≤ ub)
      (hbl : lb ≤ b) (hbu : b ≤ ub) : abs (a - b) ≤ ub - lb :=
abs_sub_le_iff.2 ⟨sub_le_sub hau hbl, sub_le_sub hbu hal⟩

lemma eq_of_abs_sub_nonpos (h : abs (a - b) ≤ 0) : a = b :=
eq_of_abs_sub_eq_zero (le_antisymm h (abs_nonneg (a - b)))

lemma exists_gt_zero [nontrivial α] : ∃ (a:α), 0 < a :=
begin
  obtain ⟨y, hy⟩ := exists_ne (0 : α),
  cases hy.lt_or_lt,
  { exact ⟨- y, neg_pos.mpr h⟩ },
  { exact ⟨y, h⟩ }
end

@[priority 100] -- see Note [lower instance priority]
instance linear_ordered_add_comm_group.to_no_top_order [nontrivial α] :
  no_top_order α :=
⟨ begin
    obtain ⟨y, hy⟩ : ∃ (a:α), 0 < a := exists_gt_zero,
    exact λ a, ⟨a + y, lt_add_of_pos_right a hy⟩
  end ⟩

@[priority 100] -- see Note [lower instance priority]
instance linear_ordered_add_comm_group.to_no_bot_order [nontrivial α] : no_bot_order α :=
⟨ begin
    obtain ⟨y, hy⟩ : ∃ (a:α), 0 < a := exists_gt_zero,
    exact λ a, ⟨a - y, sub_lt_self a hy⟩
  end ⟩

end linear_ordered_add_comm_group

/-- This is not so much a new structure as a construction mechanism
  for ordered groups, by specifying only the "positive cone" of the group. -/
class nonneg_add_comm_group (α : Type*) extends add_comm_group α :=
(nonneg : α → Prop)
(pos : α → Prop := λ a, nonneg a ∧ ¬ nonneg (neg a))
(pos_iff : ∀ a, pos a ↔ nonneg a ∧ ¬ nonneg (-a) . order_laws_tac)
(zero_nonneg : nonneg 0)
(add_nonneg : ∀ {a b}, nonneg a → nonneg b → nonneg (a + b))
(nonneg_antisymm : ∀ {a}, nonneg a → nonneg (-a) → a = 0)

namespace nonneg_add_comm_group
variable [s : nonneg_add_comm_group α]
include s

@[reducible, priority 100] -- see Note [lower instance priority]
instance to_ordered_add_comm_group : ordered_add_comm_group α :=
{ le := λ a b, nonneg (b - a),
  lt := λ a b, pos (b - a),
  lt_iff_le_not_le := λ a b, by simp; rw [pos_iff]; simp,
  le_refl := λ a, by simp [zero_nonneg],
  le_trans := λ a b c nab nbc, by simp [-sub_eq_add_neg];
    rw ← sub_add_sub_cancel; exact add_nonneg nbc nab,
  le_antisymm := λ a b nab nba, eq_of_sub_eq_zero $
    nonneg_antisymm nba (by rw neg_sub; exact nab),
  add_le_add_left := λ a b nab c, by simpa [(≤), preorder.le] using nab,
  ..s }

theorem nonneg_def {a : α} : nonneg a ↔ 0 ≤ a :=
show _ ↔ nonneg _, by simp

theorem pos_def {a : α} : pos a ↔ 0 < a :=
show _ ↔ pos _, by simp

theorem not_zero_pos : ¬ pos (0 : α) :=
mt pos_def.1 (lt_irrefl _)

theorem zero_lt_iff_nonneg_nonneg {a : α} :
  0 < a ↔ nonneg a ∧ ¬ nonneg (-a) :=
pos_def.symm.trans (pos_iff _)

theorem nonneg_total_iff :
  (∀ a : α, nonneg a ∨ nonneg (-a)) ↔
  (∀ a b : α, a ≤ b ∨ b ≤ a) :=
⟨λ h a b, by have := h (b - a); rwa [neg_sub] at this,
 λ h a, by rw [nonneg_def, nonneg_def, neg_nonneg]; apply h⟩

/--
A `nonneg_add_comm_group` is a `linear_ordered_add_comm_group`
if `nonneg` is total and decidable.
-/
def to_linear_ordered_add_comm_group
  [decidable_pred (@nonneg α _)]
  (nonneg_total : ∀ a : α, nonneg a ∨ nonneg (-a))
  : linear_ordered_add_comm_group α :=
{ le := (≤),
  lt := (<),
  le_total := nonneg_total_iff.1 nonneg_total,
  decidable_le := by apply_instance,
  decidable_lt := by apply_instance,
  ..@nonneg_add_comm_group.to_ordered_add_comm_group _ s }

end nonneg_add_comm_group

namespace order_dual

instance [ordered_add_comm_group α] : ordered_add_comm_group (order_dual α) :=
{ add_left_neg := λ a : α, add_left_neg a,
  sub := λ a b, (a - b : α),
  ..order_dual.ordered_add_comm_monoid,
  ..show add_comm_group α, by apply_instance }

instance [linear_ordered_add_comm_group α] :
  linear_ordered_add_comm_group (order_dual α) :=
{ add_le_add_left := λ a b h c, @add_le_add_left α _ b a h _,
  ..order_dual.linear_order α,
  ..show add_comm_group α, by apply_instance }

end order_dual

namespace prod

variables {G H : Type*}

@[to_additive]
instance [ordered_comm_group G] [ordered_comm_group H] :
  ordered_comm_group (G × H) :=
{ .. prod.comm_group, .. prod.partial_order G H, .. prod.ordered_cancel_comm_monoid }

end prod

section type_tags

instance [ordered_add_comm_group α] : ordered_comm_group (multiplicative α) :=
{ ..multiplicative.comm_group,
  ..multiplicative.ordered_comm_monoid }

instance [ordered_comm_group α] : ordered_add_comm_group (additive α) :=
{ ..additive.add_comm_group,
  ..additive.ordered_add_comm_monoid }

end type_tags
