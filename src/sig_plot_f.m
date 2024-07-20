function sig_plot_f(SS, f_max, titles, save_prefix)
    % Plot the signals in frequency domain
    % SS [cell]: signals
    % f_max [int]: maximum frequency
    % titles [cell]: titles of the signals
    % save_prefix [str][optional]: prefix of the saved images
    % return: None

    save_fig = true;
    if nargin < 4
        save_fig = false;
    end

    figure;
    for i = 1 : length(SS)
        subplot(length(SS), 1, i);
        plot(abs(SS{i}(1 : f_max)));
        title(titles{i});
        ylabel('Magnitude');
    end
    xlabel('Frequency (Hz)');

    if save_fig
        saveas(gcf, strcat(save_prefix, '_signal_f.png'));
    else
        waitfor(gcf);
    end
    close;

end