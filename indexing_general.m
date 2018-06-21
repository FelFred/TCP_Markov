function y = indexing_general(original_array, delta, postop_array)
    min_value = original_array(1);    
    remainder_array = mod(postop_array,delta);
    remainder_ineq = remainder_array >= delta/2;
    quotient_array = floor(postop_array/delta);
    final_value = quotient_array * delta + remainder_ineq * delta;
    index_array = (final_value - min_value)/delta + 1;
    index_array = uint64(index_array);    
    y = index_array;
end