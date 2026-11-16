% plopinvert: run per-character programs backwards. Given the output wanted, find the inputs
% that give it, one character at a time: each output character constrains only the inputs it
% reads, and a constraint is checked as soon as those inputs have values, so most choices are
% cut early. Inputs no character reads are left free (any value works).
%?- invert([in(0), plus(0, 1)], 2, [3, 5], Ins).          % Ins = [[3, 2]]
%?- invert([const(4)], 2, [4], Ins).                      % Ins = [[_, _]]: both inputs are free
%?- count([plus(0, 1)], 2, [5], N).                       % N = 10
:- module(plopinvert, [eval_char/3, run/3, dep/2, invert/4, count/4, brute/4]).
:- use_module(library(lists)).
:- use_module(library(apply)).

% Per-character formulas, as in plop2: in(I), shift(I, D) (+D mod 10), plus(I, J) (mod 10), const(C).
eval_char(in(I), In, C) :- nth0(I, In, C).
eval_char(shift(I, D), In, C) :- nth0(I, In, X), C is (X + D) mod 10.
eval_char(plus(I, J), In, C) :- nth0(I, In, X), nth0(J, In, Y), C is (X + Y) mod 10.
eval_char(const(C), _, C).
run(Fs, In, Out) :- maplist([F, C]>>eval_char(F, In, C), Fs, Out0), Out = Out0.
dep(in(I), [I]).
dep(shift(I, _), [I]).
dep(plus(I, J), D) :- sort([I, J], D).
dep(const(_), []).

% invert(+Formulas, +N, +Wanted, -Inputs): every input of length N (positions no formula reads left as
% variables) that gives Wanted, in order of the input values.
invert(Fs, N, W, Ins) :- length(Fs, L), length(W, L), findall(In, ( length(In, N), assign(Fs, W, In) ), Ins0), Ins = Ins0.
assign(Fs, W, In) :- length(In, N), Top is N - 1, numlist(0, Top, Ps), used(Fs, Used), assign_(Ps, Used, Fs, W, In).
% (a plain recursion, not a lambda: a lambda would copy In, whose places are still unbound, and lose the values set)
assign_([], _, _, _, _).
assign_([P|Ps], Used, Fs, W, In) :- ( memberchk(P, Used) -> nth0(P, In, X), between(0, 9, X), check(Fs, W, In) ; true ), assign_(Ps, Used, Fs, W, In).
used(Fs, U) :- maplist(dep, Fs, Ds), append(Ds, U0), sort(U0, U).
% every character whose inputs are all set must already be right
check(Fs, W, In) :- forall(( nth0(K, Fs, F), dep(F, D), forall(member(I, D), ( nth0(I, In, X), nonvar(X) )) ), ( nth0(K, W, C), eval_char(F, In, C) )).

% count(+Formulas, +N, +Wanted, -Count): how many full inputs over 0..9 give Wanted.
count(Fs, N, W, C) :- invert(Fs, N, W, Ins), foldl([In, A0, A]>>( include(var, In, Free), length(Free, K), A is A0 + 10 ^ K ), Ins, 0, C).

% brute(+Formulas, +N, +Wanted, -Inputs): every full input that gives Wanted (for checking).
brute(Fs, N, W, Ins) :- findall(In, ( length(In, N), maplist([X]>>between(0, 9, X), In), run(Fs, In, W) ), Ins).
