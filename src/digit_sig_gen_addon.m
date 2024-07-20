function e = digit_sig_gen_addon(N, seg_N, func)
    % Generate unit impulse signal with variable period
    % N [int]: length of the signal, including the zero padding
    % seg_N [int]: length of each segment
    % func [function]: function to generate the period of each segment
    % return [array]: unit impulse signal with variable period
    
    e = zeros(N, 1);
    idx = 1;
    while idx <= N
        e(idx) = 1;
        seg_idx = floor(idx / seg_N);
        PT = func(seg_idx);
        idx = idx + PT;
    end
    
end