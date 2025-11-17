class_name Permutations
extends RefCounted


# https://www.quickperm.org
static func get_permutations(array: Array) -> Array[Array]:
	var permutations: Array[Array] = [array.duplicate()]

	var n: int = array.size()
	var p: Array[int]
	for i in range(n + 1):
		p.append(i)

	var i: int = 1
	while i < n:
		p[i] -= 1
		var j: int = p[i] if i % 2 != 0 else 0

		var temp: int = array[j]
		array[j] = array[i]
		array[i] = temp

		permutations.append(array.duplicate())
		i = 1
		while p[i] == 0:
			p[i] = i
			i += 1

	return permutations


## Return the permutation with the lowest compromise score given by
## [param compromise_func], where 0 is a perfect score.
static func get_best_permutation(array: Array, compromise_func: Callable) -> Array:
	var best_permutation: Array
	var best_compromise: int = 2^63
	for permutation in get_permutations(array):
		var compromise: int = compromise_func.call(permutation)
		if compromise < best_compromise:
			best_permutation = permutation
			best_compromise = compromise

		if best_compromise <= 0:
			break

	return best_permutation
