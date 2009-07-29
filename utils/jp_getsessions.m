function sess = jp_getsessions(S, subnum)
%JP_GETSESSIONS Get sessions in cell array
%
% SESS = JP_GETSESSIONS(S, SUBNUM)


sess = {};

for i=1:length(S.subjects(subnum).sessions)
  sess = {sess{:} S.subjects(subnum).sessions(i).name};
end
