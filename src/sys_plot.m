function sys_plot(b, a, save_prefix)
    % Plot the zplane, freqz, impz, and impulse response of the filter
    % b [array]: numerator coefficients of the filter
    % a [array]: denominator coefficients of the filter
    % save_prefix [str][optional]: prefix of the saved images
    % return: None

    save_fig = true;
    if nargin < 3
        save_fig = false;
    end

    zplane(b, a);
    if save_fig
        saveas(gcf, strcat(save_prefix, '_zplane.png'));
    else
        waitfor(gcf);
    end
    close;

    freqz(b, a);
    if save_fig
        saveas(gcf, strcat(save_prefix, '_freqz.png'));
    else
        waitfor(gcf);
    end
    close;

    impz(b, a, 200);
    if save_fig
        saveas(gcf, strcat(save_prefix, '_impz.png'));
    else
        waitfor(gcf);
    end
    close;

    i = [1, zeros(1, 199)];
    o = filter(b, a, i);
    figure;
    stem(o);
    xlabel('n (samples)');
    ylabel('Amplitude');
    title('Impulse Response of using Filter');
    if save_fig
        saveas(gcf, strcat(save_prefix, '_impz_filter.png'));
    else
        waitfor(gcf);
    end
    close;

end