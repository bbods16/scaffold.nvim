(* lib/templates.ml  -- Template TEXT (provided data, generated from the reference). Do not edit until extension E-03. *)
(* Template data (provided fixture). Each entry: algorithm id, template text in the <% name | filter %> language. *)

let python : (string * string) list =
  [
    ( "binary-search",
      {tpl|def <% fn %>(items: list[<% elem %>], target: <% elem %>) -> int:
    """Return the index of target in the sorted list items, or -1."""
    lo, hi = 0, len(items) - 1
    while lo <= hi:
        mid = (lo + hi) // 2
        if items[mid] == target:
            return mid
        if items[mid] < target:
            lo = mid + 1
        else:
            hi = mid - 1
    return -1|tpl} );
    ( "insertion-sort",
      {tpl|def <% fn %>(items: list[<% elem %>]) -> list[<% elem %>]:
    """Return a sorted copy of items (the input is not changed)."""
    result = list(items)
    for i in range(1, len(result)):
        key = result[i]
        j = i - 1
        while j >= 0 and result[j] > key:
            result[j + 1] = result[j]
            j -= 1
        result[j + 1] = key
    return result|tpl} );
    ( "stack",
      {tpl|class <% type_name %>:
    """A last-in first-out stack of <% elem %> values."""

    def __init__(self) -> None:
        self._items: list[<% elem %>] = []

    def push(self, item: <% elem %>) -> None:
        self._items.append(item)

    def pop(self) -> "<% elem %> | None":
        return self._items.pop() if self._items else None

    def peek(self) -> "<% elem %> | None":
        return self._items[-1] if self._items else None

    def is_empty(self) -> bool:
        return not self._items

    def size(self) -> int:
        return len(self._items)|tpl} );
    ( "union-find",
      {tpl|class <% type_name %>:
    """Disjoint sets with path compression and union by size."""

    def __init__(self, n: int) -> None:
        self._parent = list(range(n))
        self._size = [1] * n

    def find(self, x: int) -> int:
        while self._parent[x] != x:
            self._parent[x] = self._parent[self._parent[x]]
            x = self._parent[x]
        return x

    def union(self, a: int, b: int) -> bool:
        ra, rb = self.find(a), self.find(b)
        if ra == rb:
            return False
        if self._size[ra] < self._size[rb]:
            ra, rb = rb, ra
        self._parent[rb] = ra
        self._size[ra] += self._size[rb]
        return True|tpl} );
  ]

let javascript : (string * string) list =
  [
    ( "binary-search",
      {tpl|/**
 * Index of target in the sorted array items, or -1.
 * @param {<% elem %>[]} items
 * @param {<% elem %>} target
 * @returns {number}
 */
function <% fn %>(items, target) {
  let lo = 0;
  let hi = items.length - 1;
  while (lo <= hi) {
    const mid = Math.floor((lo + hi) / 2);
    if (items[mid] === target) return mid;
    if (items[mid] < target) lo = mid + 1;
    else hi = mid - 1;
  }
  return -1;
}|tpl} );
    ( "insertion-sort",
      {tpl|/**
 * A sorted copy of items (the input is not changed).
 * @param {<% elem %>[]} items
 * @returns {<% elem %>[]}
 */
function <% fn %>(items) {
  const result = [...items];
  for (let i = 1; i < result.length; i++) {
    const key = result[i];
    let j = i - 1;
    while (j >= 0 && result[j] > key) {
      result[j + 1] = result[j];
      j--;
    }
    result[j + 1] = key;
  }
  return result;
}|tpl} );
    ( "stack",
      {tpl|/** A last-in first-out stack of <% elem %> values. */
class <% type_name %> {
  #items = [];

  /** @param {<% elem %>} item */
  push(item) {
    this.#items.push(item);
  }

  /** @returns {<% elem %> | undefined} */
  pop() {
    return this.#items.pop();
  }

  /** @returns {<% elem %> | undefined} */
  peek() {
    return this.#items[this.#items.length - 1];
  }

  isEmpty() {
    return this.#items.length === 0;
  }

  size() {
    return this.#items.length;
  }
}|tpl} );
    ( "union-find",
      {tpl|/** Disjoint sets with path compression and union by size. */
class <% type_name %> {
  #parent;
  #size;

  /** @param {number} n */
  constructor(n) {
    this.#parent = Array.from({ length: n }, (_, i) => i);
    this.#size = new Array(n).fill(1);
  }

  /** @param {number} x */
  find(x) {
    while (this.#parent[x] !== x) {
      this.#parent[x] = this.#parent[this.#parent[x]];
      x = this.#parent[x];
    }
    return x;
  }

  /** @returns {boolean} false if a and b were already joined */
  union(a, b) {
    let ra = this.find(a);
    let rb = this.find(b);
    if (ra === rb) return false;
    if (this.#size[ra] < this.#size[rb]) [ra, rb] = [rb, ra];
    this.#parent[rb] = ra;
    this.#size[ra] += this.#size[rb];
    return true;
  }
}|tpl} );
  ]

let ocaml : (string * string) list =
  [
    ( "binary-search",
      {tpl|(* Index of target in the sorted array items, or -1. *)
let <% fn %> (items : <% elem %> array) (target : <% elem %>) : int =
  let rec go lo hi =
    if lo > hi then -1
    else
      let mid = (lo + hi) / 2 in
      if items.(mid) = target then mid
      else if items.(mid) < target then go (mid + 1) hi
      else go lo (mid - 1)
  in
  go 0 (Array.length items - 1)|tpl} );
    ( "insertion-sort",
      {tpl|(* A sorted copy of items (the input is not changed). *)
let <% fn %> (items : <% elem %> array) : <% elem %> array =
  let result = Array.copy items in
  for i = 1 to Array.length result - 1 do
    let key = result.(i) in
    let j = ref (i - 1) in
    while !j >= 0 && result.(!j) > key do
      result.(!j + 1) <- result.(!j);
      decr j
    done;
    result.(!j + 1) <- key
  done;
  result|tpl} );
    ( "stack",
      {tpl|(* A persistent last-in first-out stack of <% elem %> values. *)
module <% type_name %> = struct
  type t = <% elem %> list

  let empty : t = []
  let is_empty (s : t) = s = []
  let push (x : <% elem %>) (s : t) : t = x :: s
  let pop (s : t) : (<% elem %> * t) option =
    match s with [] -> None | x :: rest -> Some (x, rest)
  let peek (s : t) : <% elem %> option =
    match s with [] -> None | x :: _ -> Some x
  let size (s : t) = List.length s
end|tpl} );
    ( "union-find",
      {tpl|(* Disjoint sets with path compression and union by size. *)
module <% type_name %> = struct
  type t = { parent : int array; size : int array }

  let create n = { parent = Array.init n (fun i -> i); size = Array.make n 1 }

  let rec find t x =
    if t.parent.(x) = x then x
    else begin
      let r = find t t.parent.(x) in
      t.parent.(x) <- r;
      r
    end

  let union t a b =
    let ra = find t a and rb = find t b in
    if ra = rb then false
    else begin
      let ra, rb = if t.size.(ra) < t.size.(rb) then (rb, ra) else (ra, rb) in
      t.parent.(rb) <- ra;
      t.size.(ra) <- t.size.(ra) + t.size.(rb);
      true
    end
end|tpl} );
  ]

