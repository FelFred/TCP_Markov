function y = md_approx_indexing(original_array, post_op_array)
    min_value = original_array(1);
    delta = abs(original_array(2)-original_array(1));
    final_value = round(post_op_array);
    index_array = (final_value - min_value)/delta + 1;
    index_array = uint64(index_array); 
    y = approx_index_array;
end
