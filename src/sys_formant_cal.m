function formants = sys_formant_cal(a, T)
    % Calculate the formant frequencies of a given system
    % a [array]: denominator coefficients of the system
    % T [float]: sampling period
    % return [array]: formant frequencies
    
    poles = roots(a);
    poles = poles(imag(poles) > 0);
    formants = sort(atan2(imag(poles), real(poles)) / (2 * pi * T));
    
end