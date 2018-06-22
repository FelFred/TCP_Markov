function y = collapse_to_int(original_array, value_array)
    min_value = original_array(1);
    delta = abs(original_array(2)-original_array(1));
    collapsed_array = zeros(1, length(original_array));
    for k = 1:length(value_array)
        domain_value = original_array(k);
        rounded_value = round(domain_value);
        index = (rounded_value - min_value)/delta + 1;
        index = uint64(index);
        collapsed_array(index) = collapsed_array(index) + value_array(k);
    end
    y = collapsed_array;
end