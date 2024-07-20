function sig_plot_t(ss, t, titles, save_prefix)
    % Plot the signals in time domain
    % ss [cell]: signals
    % t [array]: time
    % titles [cell]: titles of the signals
    % save_prefix [str][optional]: prefix of the saved images
    % return: None

    save_fig = true;
    if nargin < 4
        save_fig = false;
    end

    max_y = max(cellfun(@max, cellfun(@abs, ss, 'UniformOutput', false)));
    figure;
    for i = 1 : length(ss)
        subplot(length(ss), 1, i);
        plot(t, ss{i});
        title(titles{i});
        ylabel('Amplitude');
        ylim([-max_y, max_y]);
    end
    xlabel('Time (s)');
    if save_fig
        saveas(gcf, strcat(save_prefix, '_signal_t.png'));
    else
        waitfor(gcf);
    end
    close;

end