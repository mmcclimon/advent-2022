package advent

type Set[T comparable] map[T]struct{}

func NewSet[T comparable](elems ...T) Set[T] {
	s := Set[T]{}
	s.Add(elems...)
	return s
}

func (s Set[T]) Add(elems ...T) {
	for _, elem := range elems {
		s[elem] = struct{}{}
	}
}

func (s Set[T]) Intersection(other Set[T]) Set[T] {
	ret := NewSet[T]()
	for k := range s {
		if _, ok := other[k]; ok {
			ret[k] = struct{}{}
		}
	}

	return ret
}

func (s Set[T]) Union(other Set[T]) Set[T] {
	ret := NewSet[T]()
	for k := range s {
		ret[k] = struct{}{}
	}
	for k := range other {
		ret[k] = struct{}{}
	}

	return ret
}

func (s Set[T]) AnElem() T {
	for k := range s {
		return k
	}

	return *new(T)
}
