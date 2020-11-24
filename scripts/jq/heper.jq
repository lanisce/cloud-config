def join(where): [
  keys[] as $key |
  [{($key): .[$key][]}]
] | combinations | add | select(where) | add;
