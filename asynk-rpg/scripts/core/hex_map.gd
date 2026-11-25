class_name HexMap
extends RefCounted
## Reine Kartendaten fuer die Spiellogik: welche Hex-Felder begehbar sind
## und wie man von A nach B kommt. Kennt keine Nodes und keine Grafik.
##
## Koordinaten sind dieselben wie in der TileMapLayer (Layout "Diamond Down",
## Offset-Achse vertikal). In diesem Layout hat jedes Feld immer dieselben
## sechs Nachbar-Versaetze, egal in welcher Zeile es liegt.

const NEIGHBOR_OFFSETS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 1),
	Vector2i(-1, 0), Vector2i(-1, -1), Vector2i(0, -1),
]

## Begehbare Felder: Vector2i -> true
var _cells: Dictionary = {}


static func from_cells(cells: Array) -> HexMap:
	var m := HexMap.new()
	for c in cells:
		m._cells[c] = true
	return m


func is_walkable(cell: Vector2i) -> bool:
	return _cells.has(cell)


func cell_count() -> int:
	return _cells.size()


func neighbors(cell: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for o in NEIGHBOR_OFFSETS:
		var n := cell + o
		if is_walkable(n):
			result.append(n)
	return result


func are_neighbors(a: Vector2i, b: Vector2i) -> bool:
	return NEIGHBOR_OFFSETS.has(b - a)


## Kuerzester Weg (Breitensuche). Liefert die Felder NACH dem Start bis
## einschliesslich Ziel, oder [] wenn es keinen Weg gibt.
## blocked: Felder, die nicht betreten werden duerfen (z.B. andere Figuren).
## max_steps: Suche bricht ab, wenn der Weg laenger wuerde (-1 = unbegrenzt).
func find_path(from: Vector2i, to: Vector2i, blocked: Array = [], max_steps: int = -1) -> Array[Vector2i]:
	var empty: Array[Vector2i] = []
	if from == to or not is_walkable(to) or blocked.has(to):
		return empty
	var came_from := {from: from}
	var dist := {from: 0}
	var queue: Array[Vector2i] = [from]
	var head := 0
	while head < queue.size():
		var cur: Vector2i = queue[head]
		head += 1
		if cur == to:
			break
		if max_steps >= 0 and dist[cur] >= max_steps:
			continue
		for n in neighbors(cur):
			if came_from.has(n) or blocked.has(n):
				continue
			came_from[n] = cur
			dist[n] = dist[cur] + 1
			queue.append(n)
	if not came_from.has(to):
		return empty
	var path: Array[Vector2i] = []
	var c := to
	while c != from:
		path.push_front(c)
		c = came_from[c]
	return path
