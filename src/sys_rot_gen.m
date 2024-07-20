function rot_a = sys_rot_gen(a, angle)
    % Generate the rotated system
    % a [array]: denominator coefficients of the system
    % angle [float]: angle of rotation in radians
    % return [array]: denominator coefficients of the rotated system

    poles = roots(a);
    real_poles = poles(imag(poles) == 0);
    imag_poles = poles(imag(poles) > 0);
    imag_poles = imag_poles .* exp(1i * angle);
    all_poles = [imag_poles; conj(imag_poles); real_poles];
    rot_a = poly(all_poles) * a(1);

end