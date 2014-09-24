function [i_start] = set_break()
    load('test_break')    ;
if cellfun('isempty',final_result{1,i}{j,m}{n,q}) & cellfun('isempty',temp_result{j,m}{n,q}) & cellfun('isempty',test_result{n,q})
        i_start = i+1;
    end
end
