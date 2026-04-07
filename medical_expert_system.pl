:- use_module(library(readutil)).

:- dynamic known/2.

% ------------------------------------------------------------
% Medical Expert System (educational demo only)
% Classical Rule-Based AI in Prolog
% ------------------------------------------------------------

main :-
    banner,
    collect_symptoms,
    diagnose,
    reset_session.

banner :-
    nl,
    writeln('==============================================='),
    writeln('  Medical Expert System (Educational Project)'),
    writeln('==============================================='),
    writeln('This system is for academic demonstration only.'),
    writeln('It is not a substitute for professional medical advice.'),
    nl.

reset_session :-
    retractall(known(_, _)).

% ------------------------------------------------------------
% User interaction
% ------------------------------------------------------------

collect_symptoms :-
    writeln('Please answer yes or no for each symptom.'),
    writeln('Type yes, y, no, or n, then press Enter.'),
    nl,
    forall(symptom(Symptom, Prompt), ask_symptom(Symptom, Prompt)),
    nl.

ask_symptom(Symptom, Prompt) :-
    (   known(Symptom, _)
    ->  true
    ;   format('Do you have ~w? ', [Prompt]),
        read_user_answer(Answer),
        assertz(known(Symptom, Answer))
    ).

read_user_answer(Answer) :-
    read_line_to_string(user_input, Input),
    normalize_answer(Input, Answer),
    (   Answer = yes
    ;   Answer = no
    ),
    !.
read_user_answer(Answer) :-
    writeln('Please type yes, y, no, or n.'),
    read_user_answer(Answer).

normalize_answer(Input, yes) :-
    string_lower(Input, Lower),
    normalize_space(string(Norm), Lower),
    member(Norm, ["yes", "y"]).
normalize_answer(Input, no) :-
    string_lower(Input, Lower),
    normalize_space(string(Norm), Lower),
    member(Norm, ["no", "n"]).
normalize_answer(_, unknown) :-
    fail.

has_symptom(Symptom) :-
    known(Symptom, yes).

user_yes_symptom(Symptom) :-
    has_symptom(Symptom).

% ------------------------------------------------------------
% Knowledge base
% ------------------------------------------------------------

symptom(fever, 'fever').
symptom(cough, 'cough').
symptom(body_aches, 'body aches').
symptom(fatigue, 'fatigue').
symptom(chills, 'chills').
symptom(headache, 'headache').
symptom(sore_throat, 'a sore throat').
symptom(runny_nose, 'a runny nose').
symptom(sneezing, 'sneezing').
symptom(mild_fever, 'a mild fever').
symptom(nausea, 'nausea').
symptom(vomiting, 'vomiting').
symptom(diarrhea, 'diarrhea').
symptom(stomach_pain, 'stomach pain').
symptom(itchy_eyes, 'itchy eyes').
symptom(watery_eyes, 'watery eyes').
symptom(swollen_lymph_nodes, 'swollen lymph nodes').
symptom(facial_pain, 'facial pain or pressure').
symptom(congestion, 'nasal congestion').
symptom(chest_discomfort, 'chest discomfort').
symptom(shortness_of_breath, 'shortness of breath').
symptom(wheezing, 'wheezing').
symptom(thirst, 'excessive thirst').
symptom(dry_mouth, 'dry mouth').
symptom(dizziness, 'dizziness').
symptom(dark_urine, 'dark urine').
symptom(abdominal_cramps, 'abdominal cramps').
symptom(sensitivity_light, 'sensitivity to light').
symptom(sensitivity_sound, 'sensitivity to sound').
symptom(blurred_vision, 'blurred vision').

% disease(Name, RequiredSymptoms, Description, Advice)

disease(flu,
    [fever, cough, body_aches, fatigue, chills, headache],
    'The symptom pattern is consistent with influenza.',
    'Rest, drink fluids, and seek medical attention if symptoms become severe.').

disease(common_cold,
    [cough, sore_throat, runny_nose, sneezing, mild_fever],
    'The symptom pattern is consistent with the common cold.',
    'Rest, hydrate, and monitor symptoms.').

disease(migraine,
    [headache, nausea, sensitivity_light, sensitivity_sound],
    'The symptom pattern is consistent with a migraine.',
    'Rest in a quiet dark room and seek medical advice if headaches persist.').

disease(food_poisoning,
    [nausea, vomiting, diarrhea, stomach_pain, fever],
    'The symptom pattern is consistent with food poisoning.',
    'Stay hydrated and seek medical help if dehydration occurs.').

disease(seasonal_allergies,
    [sneezing, runny_nose, itchy_eyes, watery_eyes],
    'The symptom pattern is consistent with seasonal allergies.',
    'Avoid triggers and consider speaking with a healthcare professional.').

disease(strep_throat,
    [sore_throat, fever, swollen_lymph_nodes, headache],
    'The symptom pattern is consistent with strep throat.',
    'A medical evaluation may be needed for confirmation and treatment.').

disease(sinus_infection,
    [facial_pain, congestion, headache, runny_nose, fever],
    'The symptom pattern is consistent with a sinus infection.',
    'Rest, hydrate, and consult a healthcare professional if symptoms continue.').

disease(bronchitis,
    [cough, chest_discomfort, fatigue, shortness_of_breath, wheezing],
    'The symptom pattern is consistent with bronchitis.',
    'Seek medical advice if breathing becomes difficult.').

disease(dehydration,
    [thirst, dry_mouth, dizziness, dark_urine, fatigue],
    'The symptom pattern is consistent with dehydration.',
    'Drink water or an electrolyte solution and seek help if severe.').

disease(gastroenteritis,
    [nausea, vomiting, diarrhea, abdominal_cramps, fever],
    'The symptom pattern is consistent with gastroenteritis.',
    'Rest, hydrate, and seek care if symptoms worsen.').

% ------------------------------------------------------------
% Inference and diagnosis
% ------------------------------------------------------------

collect_yes_symptoms(YesSymptoms) :-
    findall(S, user_yes_symptom(S), YesSymptoms).

exact_diagnosis(Disease) :-
    disease(Disease, RequiredSymptoms, _, _),
    collect_yes_symptoms(YesSymptoms),
    subset_list(RequiredSymptoms, YesSymptoms).

possible_diagnosis(Disease, Score, MatchedSymptoms, RequiredSymptoms, Description, Advice) :-
    disease(Disease, RequiredSymptoms, Description, Advice),
    collect_yes_symptoms(YesSymptoms),
    matched_symptoms(RequiredSymptoms, YesSymptoms, MatchedSymptoms),
    length(RequiredSymptoms, Total),
    length(MatchedSymptoms, MatchedCount),
    Total > 0,
    Score is round((MatchedCount / Total) * 100).

matched_symptoms([], _, []).
matched_symptoms([H|T], YesSymptoms, [H|MatchedT]) :-
    memberchk(H, YesSymptoms),
    !,
    matched_symptoms(T, YesSymptoms, MatchedT).
matched_symptoms([_|T], YesSymptoms, MatchedT) :-
    matched_symptoms(T, YesSymptoms, MatchedT).

subset_list([], _).
subset_list([H|T], List) :-
    memberchk(H, List),
    subset_list(T, List).

rank_diagnoses(Ranked) :-
    findall(NegScore-Disease-Matched-Required-Description-Advice,
        ( possible_diagnosis(Disease, Score, Matched, Required, Description, Advice),
          Score > 0,
          NegScore is -Score
        ),
        Pairs),
    keysort(Pairs, Sorted),
    reverse(Sorted, Ranked).

show_exact_diagnoses :-
    findall(D, exact_diagnosis(D), Exact),
    (   Exact = []
    ->  writeln('No exact diagnosis matched all required symptoms.')
    ;   writeln('Exact diagnosis match(es):'),
        forall(member(Disease, Exact), format(' - ~w~n', [Disease]))
    ),
    nl.

show_ranked_diagnoses :-
    rank_diagnoses(Ranked),
    (   Ranked = []
    ->  writeln('No probable diagnosis could be identified from the provided symptoms.'),
        writeln('Try entering additional symptoms or review the symptom list.'),
        nl
    ;   writeln('Probable diagnosis ranking:'),
        forall(member(NegScore-Disease-Matched-Required-Description-Advice, Ranked),
            print_ranked_result(NegScore, Disease, Matched, Required, Description, Advice)),
        nl
    ).

print_ranked_result(NegScore, Disease, Matched, Required, Description, Advice) :-
    Score is -NegScore,
    length(Matched, MatchedCount),
    length(Required, RequiredCount),
    format('~nDiagnosis: ~w~n', [Disease]),
    format('Confidence: ~w% (~w of ~w core symptoms matched)~n', [Score, MatchedCount, RequiredCount]),
    format('Matched symptoms: ~w~n', [Matched]),
    format('Reasoning: ~w~n', [Description]),
    format('Advice: ~w~n', [Advice]).

show_user_summary :-
    collect_yes_symptoms(YesSymptoms),
    format('~nSymptoms entered: ~w~n', [YesSymptoms]).

show_final_note :-
    nl,
    writeln('This result is only a classroom demonstration of rule-based reasoning.'),
    writeln('It is not medical advice or a real diagnostic system.'),
    nl.

% ------------------------------------------------------------
% Main diagnosis pipeline
% ------------------------------------------------------------

diagnose :-
    show_user_summary,
    show_exact_diagnoses,
    show_ranked_diagnoses,
    show_final_note.

