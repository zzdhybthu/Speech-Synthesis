function sig_sound(s, fs)
    % Play the sound of the signal
    % s [array]: signal
    % fs [float]: sampling frequency
    % return: None

    sound(s / max(abs(s)), fs);
    pause(length(s) / fs);
    
end