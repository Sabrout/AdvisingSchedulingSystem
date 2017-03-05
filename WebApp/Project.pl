:- use_module(library(clpfd)).

 
%% Loops on the given history of the student and removes the courses that have a grade of "FA".
is_attended([], []).

is_attended([[N,G]|T], [NA|TA]):-
	\+ G = "FA",
	is_attended(T, TA),
	NA = N.

is_attended([[_,G]|T], LR):-
	G = "FA",
	is_attended(T, LR).


%% Checks if the first list is a subset of the second list.
member_list([],_).

member_list([H|T], Hist):-
	element(_, Hist, H),
	member_list(T, Hist).


%% Filters a given curriculum by looping on its courses. For each course curr_filter does:
%% 		1. Add obligatory courses to the filtered curriculum. 
%% 		2. If the course is not obligatory, the prerequisites of the course is compared to the student's history.
%% 		3. If the prerequisites is a subset of the history, the course is added to the filtered curriculum.
%% 		4. else, the course is disregarded. 
curr_filter([], _, _, [], []).

curr_filter([[Name, Ch, _]|Curr], History, Oblig, [Name|FCurr], [Ch|Chours]):-
	element(_, Oblig, Name),
	curr_filter(Curr, History, Oblig, FCurr, Chours).

curr_filter([[Name, Ch, Pre]|Curr], History, Oblig, [Name|FCurr], [Ch|Chours]):-
	\+ element(_, Oblig, Name),
	member_list(Pre, History),
	curr_filter(Curr, History, Oblig, FCurr, Chours).

curr_filter([[Name, _, Pre]|TC], History, Oblig, FCurr, Chours):-
	\+ element(_, Oblig, Name),
	\+ member_list(Pre, History),
	curr_filter(TC, History, Oblig, FCurr, Chours).


%% Loops on given list of courses and returns a list of names of these courses.
course_names([], []).

course_names([[N, _, _]|TL], [N|TN]):-
	course_names(TL,TN).


%% Loops on a given list of integers and returns the sum of these integers.
sum_list1([], 0).

sum_list1([H|T], S):-
	sum_list1(T, S1),
	S #= S1 + H.


%% Given a binary list and a list of courses, corr_courses returns a list of courses that have a corresponding value of 1 in the binary list,
%% and omits the courses with a corresponding binary value of 0.
corr_courses([], [], []).

corr_courses([HC|TC], [HL|TL], [HC|TO]):-
	HL = 1, 
	corr_courses(TC, TL, TO).

corr_courses([_|TC], [HL|TL], TO):-
	HL = 0, 
	corr_courses(TC, TL, TO).


%% Given a list of courses' credit hours, all_sum creates a randomized list of binaries that represents the courses taken,
%% and calculates the credit hours of the taken courses. 
all_sum([], 0, []).

all_sum([H|T], S, [HS|TS]):-
	all_sum(T, S1, TS),
	HS#=1 #==> S#=S1+H,
	HS#=0 #==> S#=S1.


%% Aims to choose the courses that maximizes the value of credit hours without exceeding the credit limit given. 
%% It does so by introducing a binary array called Labels, with the same length of the courses list, which represents the courses taken by value of 1 and courses neglected by value of 0.
%% It then calculates the Total credit hours of the chosen courses. 
%% The clpfd predefined method Labeling is used to assign values to the unbound binary list (Labels), while maximizing the total credit hours of the chosen courses.
max_credits(Credits, Courses, CredLimit, Prob, Output, Out_Credits):-
	all_sum(Credits, TotalCH, Labels),
	Labels ins 0 .. 1,
	TotalCH in 0..40,
	((TotalCH #=< CredLimit, Prob);
	(TotalCH #=< CredLimit + 3, \+ Prob)),
	sum_list1(Labels, S),
	labeling([max(TotalCH), max(S)], Labels),
	corr_courses(Courses, Labels, Output),
	corr_courses(Credits, Labels, Out_Credits).


%% Removes the obligatory courses from the Course names list , the course credit hours list and credit limit.
cal_oblig(Oblig, ObligCH, FNames, FCH, CredLimit, CNames, CCH, NCredLimit):- 
	sub_list(Oblig, FNames, CNames),
	sub_list(ObligCH, FCH, CCH),
	sum_list(ObligCH, TotalCH),
	NCredLimit is CredLimit - TotalCH.


%% IMPORTANT: Order the Oblig list
%% Removes the first list elements from the second list and output the resultant list. 
sub_list([], X, X).

sub_list([H|TO], [HN|TN], [HN|TC]):-
	\+ H =HN,
	sub_list([H|TO], TN, TC).

sub_list([H|TO], [H|TN], TC):-
	sub_list(TO, TN, TC).


%% Given the schedule of all of the courses and a list of the chosen courses, 
%% sched_filter predicate filters the schedule by removing all the courses not included in the chosen courses list.
sched_filter([], _, []).

sched_filter([H|T], CNames, [H|TF]):-
	analyze(H, _, Name, _, _, _, _, _, _),
	member(Name, CNames),
	sched_filter(T, CNames, TF).

sched_filter([H|T], CNames, TF):-
	analyze(H, _, Name, _, _, _, _, _, _),
	\+ member(Name, CNames),
	sched_filter(T, CNames, TF).


%% Divides a given meeting into Semester, Course name, Lecture group, Tutorial group and Time(Day, Slot).
analyze(Meeting, Semester, Cname, Type, LGroup, TGroup, Time, Day, Slot):-
	divmod1(Meeting, 100, Meeting1, Time),
	divmod1(Time, 10, Day, Slot),
	divmod1(Meeting1, 100, Meeting2, TGroup),
	divmod1(Meeting2, 100, Meeting3, LGroup),
	divmod1(Meeting3, 100, Meeting4, Type),
	divmod1(Meeting4, 100, Semester, Cname).


%% Divides a given integer by a given divisor, then outputs the Quotient and the remainder resulted.
divmod1(Int, Div, Quo, Rem):-
	Rem #= Int mod Div,
	Quo #= Int // Div.


%% Divides schedule into list of lists. Each list contains all the meetings of a single course with a certain type.
divide_sched([], []).

divide_sched([HS|TS], Div_Sched):-
	divide_sched(TS, Div_Sched1),
	once(place(HS, Div_Sched1, Div_Sched)).


%% Places a given meeting in a given list of lists resulting in an updated list of lists. 
place(HS, [], [[HS]]).

place(Meeting, [[HM|TM]|T], [HN|TN]):-
	analyze(Meeting, _, Cname, Type, _, _, _, _, _),
	analyze(HM, _, Cname1, Type1, _, _, _, _, _),
	Cname1 = Cname,
	Type1 = Type,
	append([Meeting], [HM|TM], HN),
	TN = T.

place(Meeting, [[HM|TM]|T], [[HM|TM]|TN]):-
	analyze(Meeting, _, Cname, Type, _, _, _, _, _),
	analyze(HM, _, Cname1, Type1, _, _, _, _, _),
	(Cname1 =\= Cname;
	Type1 =\= Type),
	place(Meeting, T, TN).


%% Randomly choose a meeting from every list.
create_PSched([], []).

create_PSched([H|T], [HP|TP]):-
	element(_, H, HP),
	create_PSched(T, TP).


%% Applies different constraint on the final schedule.
constraints(VarSchedule, Sched_Days, TGroupVar, SGroupVar):-
	unique_times(VarSchedule),
	tut_lab(VarSchedule),
	same_group(VarSchedule, TGroupVar),
	same_sem_grp(VarSchedule, SGroupVar),
	day_off(VarSchedule, Sched_Days).


%% Assures that the timings of every meeting in the final schedule are distinct.
unique_times(VarSchedule):-
	get_times(VarSchedule, Times),
	all_distinct(Times).


%% Gets the timings of every meeting in the final schedule
get_times([], []).

get_times([H|T], [HT|TT]):-
	analyze(H, _, _, _, _, _, HT, _, _),
	get_times(T, TT).


%% Assures that the schedule contains atleast one day off.
day_off(VarSchedule, Sched_Days):-
	get_days(VarSchedule, Days),
	L = [A, B, C, D, E, F],
	L ins 0 .. 1,
	Sum #= A + B + C+ D + E + F,
	Sum #=< Sched_Days,
	day_helper(Days, L).


%% Returns a list containing the occupied days in the final schedule.
get_days([], []).

get_days([H|T], [HD|TD]):-
	analyze(H, _, _, _, _, _, _, HD, _),
	get_days(T, TD).


%% Assigns 1 in the list L for every day in the schedule. 
day_helper([], _).

day_helper([H|T], L):-
	element(H, L, 1),
	day_helper(T, L).


%% Assures that each tutorial precedes labs of the same course.
tut_lab([]).

tut_lab([H|T]):-
	tut_lab_helper(H, T),
	tut_lab(T).


%% Compares a given meeting with a list of meetings to assure that 
%% the timing of each tutorial precedes each lab of the same course.
tut_lab_helper(_, []).

tut_lab_helper(H, [H1|T]):-
	analyze(H, _, Cname, Type, _, TGroup, Time, _, _),
	analyze(H1, _, Cname1, Type1, _, TGroup1, Time1, _, _),
	(Cname1 #= Cname #/\ TGroup #\= 0 #/\ TGroup1 #\= 0 #/\ 
	Type #< Type1 #==> Time #< Time1),
	(Cname1 #= Cname #/\ TGroup #\= 0 #/\ TGroup1 #\= 0 #/\ 
	Type #> Type1 #==> Time #> Time1),
	tut_lab_helper(H, T).


%% Adds a soft constraint, which prefers schedules with same tutorial group.
same_group([], 0).

same_group([H|T], S):-
	same_group_helper(H, T, S1),
	same_group(T, S2),
	S #= S1 +S2.


%% Compares a given meeting with a list of meetings to calculate the difference between the tutorial groups in a given schedule.
same_group_helper(_, [], 0).

same_group_helper(H, [H1|T], S):-
	analyze(H, _, Cname, _, _, TGroup, _, _, _),
	analyze(H1, _, Cname1, _, _, TGroup1, _, _, _),
	same_group_helper(H, T, S1),
	(Cname1 #= Cname #/\ TGroup #\= 0 #/\ TGroup1 #\= 0 
		#==> Sdiff #= abs(TGroup1 - TGroup) #/\ S#= S1 + Sdiff),
	(Cname1 #\= Cname #\/ TGroup #= 0 #\/ TGroup1 #= 0 #==> S#= S1).


%% Gets the number of gap slots in a given schedule.
get_gaps(VarSchedule, Gaps):-
	get_total_slots(VarSchedule, 1, TotalSlots),
	length(VarSchedule, Slots),
	Gaps #= TotalSlots - Slots.



get_total_slots(_, 7, 0).

get_total_slots(VarSchedule, Day, TotalSlots):-
	Day1 #= Day + 1,
	get_total_slots(VarSchedule, Day1, TotalSlots1),
	get_day_slots(VarSchedule, Day, Slots),
	Slots #> 0 #==> TotalSlots #= TotalSlots1 + Slots,
	Slots #< 0 #==> TotalSlots #= TotalSlots1. 


get_day_slots(VarSchedule, Day, Slots):-
	get_min_day(VarSchedule, Day, Min),
	get_max_day(VarSchedule, Day, Max),
	Slots #= Max - Min + 1.


get_min_day([], _, MinSoFar):-
	MinSoFar #= 5.

get_min_day([H|T], D, Min):-
	get_min_day(T, D, MinSoFar),
	analyze(H, _, _, _, _, _, _, DH, S),
	D #= DH #==> Min #= min(S, MinSoFar),
	D #\= DH #==> Min #= MinSoFar.

get_max_day([], _, MaxSoFar):-
	MaxSoFar #= 0.

get_max_day([H|T], D, Max):-
	get_max_day(T, D, MaxSoFar),
	analyze(H, _, _, _, _, _, _, DH, S),
	D #= DH #==> Max #= max(S, MaxSoFar),
	D #\= DH #==> Max #= MaxSoFar.


%% Adds a soft constraint, which prefers schedules with less difference in the tutorial an lecture groups in a specific semester.
same_sem_grp([], 0).

same_sem_grp([H|T], S):-
	same_sem_group_helper(H, T, S1),
	same_sem_grp(T, S2),
	S #= S1 +S2.

%% Compares a given meeting with a list of meetings to calculate the difference between the tutorial groups and lecture groups in a given schedule.
same_sem_group_helper(_, [], 0).

same_sem_group_helper(H, [H1|T], S):-
	analyze(H, Semester, _, _, LGroup, TGroup, _, _, _),
	analyze(H1, Semester1, _, _, LGroup1, TGroup1, _, _, _),
	same_sem_group_helper(H, T, S1),
	(Semester #= Semester1 #/\ TGroup #\= 0 #/\ TGroup1 #\= 0
		#==> Sdiff #= abs(TGroup - TGroup1) #/\ 
		Sdiff1 #= abs(LGroup - LGroup1) #/\ S #= S1 + Sdiff + Sdiff1),
	(Semester #= Semester1 #/\ (TGroup #= 0 #\/ TGroup1 #= 0)
		#==> Sdiff #= abs(LGroup - LGroup1) #/\ S #= S1 + Sdiff),
	(Semester #\= Semester1 #==> S#= S1).


%% The main Predicate that calls all of the aforementioned predicates. 
%% It takes as input the following:
%% the curriculum, history of the student, obligatory courses, obligatory credit hours,
%% credit hours limit, schedule containing all the courses, whether the student on probation or not , the maximum number of days.
%% and outputs the Final schedule.
schedule(Curr, History, Oblig, ObligCH, CredLimit, Schedule, 
										Prob, Sched_Days, VarSchedule):-
	is_attended(History, Att),
	curr_filter(Curr, Att, Oblig, FNames, FCH),
	cal_oblig(Oblig, ObligCH, FNames, FCH, CredLimit, CNames, CCH, NCredLimit),
	max_credits(CCH, CNames, NCredLimit, Prob, Output, Out_Credits),
	append(Oblig, Output, TCN),
	append(ObligCH, Out_Credits, TCH),
	print("TCN"),
	print(TCN), nl,
	print("TCH"),
	print(TCH), nl,
	sched_filter(Schedule, TCN, FSchedule),
	divide_sched(FSchedule, DSchedule),
	create_PSched(DSchedule, VarSchedule),
	constraints(VarSchedule, Sched_Days, TGroupVar, SGroupVar),
	get_gaps(VarSchedule, Gaps),
	labeling([min(Gaps), min(TGroupVar), min(SGroupVar)], VarSchedule),
	print('TGroupVar: '),
	print(TGroupVar),nl,
	print('SGroupVar: '),
	print(SGroupVar),nl,
	print('Gaps: '),
	print(Gaps), nl.
