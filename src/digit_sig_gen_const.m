function e = digit_sig_gen_const(PT, N)
    % Generate unit impulse signal
    % PT [int]: period
    % N [int]: length of the signal, including the zero padding
    % return [array]: unit impulse signal

    e = zeros(N, 1);
    e(1 : PT : N) = 1;
    
end