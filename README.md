# plopinvert

run per-character programs backwards. Given the output wanted, find the inputs that give it, one character at a time: each output character constrains only the inputs it reads, and a constraint is checked as soon as those inputs have values, so most choices are cut early. Inputs no character reads are left free (any value works).

## Use

```prolog
?- use_module(prolog/plopinvert).
?- invert([in(0), plus(0, 1)], 2, [3, 5], Ins).          % Ins = [[3, 2]]
?- invert([const(4)], 2, [4], Ins).                      % Ins = [[_, _]]: both inputs are free
?- count([plus(0, 1)], 2, [5], N).                       % N = 10
```

## Proofs

`proofs/theorems.pl` proves 4 theorems by exhaustion: each one is checked for every case in a finite domain that covers every branch of the definitions. every 2-character program from a pool, inputs of length 2 over 0..9, every reachable and some unreachable outputs.

1. Sound: every input found gives the wanted output (whatever is put in its free places).
2. Complete: the count matches trying every input.
3. An output that nothing gives has no inputs.
4. Positions no character reads are always left free.

```sh
swipl -g main -t halt proofs/theorems.pl
```

## 200 inputs and outputs

`io/ios.txt` lists 200 inputs and outputs from real runs, and `io/ios.pl` has the same as Prolog facts. The inputs come from a fixed seed (`io/cases.pl`). `swipl -g check -t halt io/run.pl` runs them again. It fails if any output changes, or if a predicate doesn't confirm its own recorded output, which checks steadfastness. GitHub Actions runs the proofs and the examples on every push, and records the examples on the first push.

Licence: BSD-3-Clause.
