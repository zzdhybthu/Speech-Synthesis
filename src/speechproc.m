function speechproc()

    % 定义常数
    FL = 80;  % 帧长
    WL = 240;  % 窗长
    P = 10;  % 预测系数个数
    s = readspeech('./resource/voice.pcm', 100000);  % 载入语音
    L = length(s);  % 读入语音长度
    FN = floor(L/FL) - 2;  % 计算帧数
    % 预测和重建滤波器
    exc = zeros(L, 1);  % 激励信号（预测误差）
    zi_pre = zeros(P, 1);  % 预测滤波器的状态
    s_rec = zeros(L, 1);  % 重建语音
    zi_rec = zeros(P, 1);
    % 合成滤波器
    exc_syn = zeros(L, 1);  % 合成的激励信号（脉冲串）
    s_syn = zeros(L, 1);  % 合成语音
    zi_syn = zeros(P,1);  % 合成滤波器的状态
    % 变调不变速滤波器
    exc_syn_t = zeros(L, 1);  % 合成的激励信号（脉冲串）
    s_syn_t = zeros(L, 1);  % 合成语音
    zi_syn_t = zeros(P, 1);  % 合成滤波器的状态
    % 变速不变调滤波器（假设速度减慢一倍）
    exc_syn_v = zeros(2 * L, 1);  % 合成的激励信号（脉冲串）
    s_syn_v = zeros(2 * L, 1);  % 合成语音
    FL_v = 2 * FL;  % 新的帧长
    zi_syn_v = zeros(P, 1);  % 合成滤波器的状态

    hw = hamming(WL);  % 汉明窗
    
    % 依次处理每帧语音
    for n = 3 : FN

        % 计算预测系数
        s_w = s(n * FL - WL + 1 : n * FL) .* hw;  %汉明窗加权后的语音
        [A E] = lpc(s_w, P);  %用线性预测法计算P个预测系数, A 是预测系数, E 被用来计算合成激励的能量

        if n == 27
            % (3) 观察预测系统的零极点图
            B = [1, zeros(1, P)];
            zplane(A, 1);
            % waitfor(gcf);
            saveas(gcf, './report/asserts/1_3_zplane.png');    
            close;        
        end
        
        s_f = s((n - 1) * FL + 1 : n * FL);  % 本帧语音

        % (4) 用filter函数 s_f 计算激励，注意保持滤波器状态
        [exc((n - 1) * FL + 1 : n * FL), zi_pre] = filter(A, 1, s_f, zi_pre);
        

        % (5) 用 filter 函数和 exc 重建语音，注意保持滤波器状态
        [s_rec((n - 1) * FL + 1 : n * FL), zi_rec] = filter(1, A, exc((n - 1) * FL + 1 : n * FL), zi_rec);
        

        s_Pitch = exc(n * FL - 222 : n * FL);
        PT = findpitch(s_Pitch);  % 计算基音周期 PT
        G = sqrt(E * PT);  % 计算合成激励的能量 G
        
        % (10) 生成合成激励，并用激励和 filter 函数产生合成语音
        exc_syn((n - 1) * FL + 1 : n * FL) = G * digit_sig_gen_const(PT, FL);
        [s_syn((n - 1) * FL + 1 : n * FL), zi_syn] = filter(1, A, exc_syn((n - 1) * FL + 1 : n * FL), zi_syn);
        

        % (11) 不改变基音周期和预测系数，将合成激励的长度增加一倍，再作为 filter 的输入得到新的合成语音
        exc_syn_v((n - 1) * FL_v + 1 : n * FL_v) = G * digit_sig_gen_const(PT, FL_v);
        [s_syn_v((n - 1) * FL_v + 1 : n * FL_v), zi_syn_v] = filter(1, A, exc_syn_v((n - 1) * FL_v + 1 : n * FL_v), zi_syn_v);
        

        % (13) 将基音周期减小一半，将共振峰频率增加150Hz，重新合成语音
        rot_A = sys_rot_gen(A, 150 * 2 * pi / 8000);
        exc_syn_t((n - 1) * FL + 1 : n * FL) = G * digit_sig_gen_const(round(PT / 2), FL);
        [s_syn_t((n - 1) * FL + 1 : n * FL), zi_syn_t] = filter(1, rot_A, exc_syn_t((n - 1) * FL + 1 : n * FL), zi_syn_t);
        
    end

    % (1)

    % calculate the formant frequencies of the system
    a = [1, -1.3789, 0.9506];
    formants = sys_formant_cal(a, 1 / 8000);
    formants

    % plot the system
    % sys_plot(1, a);
    sys_plot(1, a, './report/asserts/1_1');


    % (6)

    % sound the original signal, excitation signal, and reconstructed signal
    sig_sound([s; exc; s_rec], 8000);

    % plot the signals in time domain
    t = [1 : L] / 8000;
    titles = {'Original Signal', 'Excitation Signal', 'Reconstructed Signal'};
    % sig_plot_t({s, exc, s_rec, t, titles);
    sig_plot_t({s, exc, s_rec}, t, titles, './report/asserts/1_6');

    % plot clipped signals in time domain
    start_s = 1000;
    end_s = 1500;
    s_clip = s(start_s : end_s);
    exc_clip = exc(start_s : end_s);
    s_rec_clip = s_rec(start_s : end_s);
    t = [1 : (end_s - start_s + 1)] / 8000 + start_s / 8000;
    titles = {'Original Signal (Clipped)', 'Excitation Signal (Clipped)', 'Reconstructed Signal (Clipped)'};
    % sig_plot_t({s_clip, exc_clip, s_rec_clip}, t, titles);
    sig_plot_t({s_clip, exc_clip, s_rec_clip}, t, titles, './report/asserts/1_6_clipped');

    % plot the signals in frequency domain
    titles = {'Original Signal Spectrum', 'Excitation Signal Spectrum', 'Reconstructed Signal Spectrum'};
    % sig_plot_f({fft(s), fft(exc), fft(s_rec)}, 8000, titles);
    sig_plot_f({fft(s), fft(exc), fft(s_rec)}, 8000, titles, './report/asserts/1_6');


    % (7)

    % generate a unit impulse signal
    e200 = digit_sig_gen_const(8000 / 200, 8000);
    e300 = digit_sig_gen_const(8000 / 300, 8000);

    % sound it
    sig_sound([e200; e300], 8000);
    

    % (8)

    % generate a unit impulse signal with variable period
    e_addon = digit_sig_gen_addon(8000, 80, @(x) 80 + 5 * mod(x, 50));

    % sound it
    sig_sound(e_addon, 8000);


    % (9)

    % pass the unit impulse signal with variable period through the filter
    s_addon = filter(1, [1, -1.3789, 0.9506], e_addon);

    % sound it
    sig_sound(s_addon, 8000);

    % plot the signals in time domain
    t = [1 : 8000] / 8000;
    titles = {'Excitation Signal with Variable Period', 'Filtered Excitation Signal with Variable Period'};
    % sig_plot_t({e_addon, s_addon}, t, titles);
    sig_plot_t({e_addon, s_addon}, t, titles, './report/asserts/1_9');

    % plot the signals in frequency domain
    titles = {'Excitation Signal with Variable Period Spectrum', 'Filtered Excitation Signal with Variable Period Spectrum'};
    % sig_plot_f({fft(e_addon), fft(s_addon)}, 8000, titles);
    sig_plot_f({fft(e_addon), fft(s_addon)}, 8000, titles, './report/asserts/1_9');


    % (10)

    % sound the synthesized signal
    sig_sound(s_syn, 8000);

    % plot the signals in time domain
    t = [1 : L] / 8000;
    titles = {'Original Signal', 'Synthesized Signal'};
    % sig_plot_t({s, s_syn}, t, titles);
    sig_plot_t({s, s_syn}, t, titles, './report/asserts/1_10_synthesized');

    % plot the signals in frequency domain
    titles = {'Original Signal Spectrum', 'Synthesized Signal Spectrum'};
    % sig_plot_f({fft(s), fft(s_syn)}, 4000, titles);
    sig_plot_f({fft(s), fft(s_syn)}, 4000, titles, './report/asserts/1_10_synthesized');


    % (11)

    % sound the synthesized signal (speed reduced)
    sig_sound(s_syn_v, 8000);

    % plot the signals in time domain
    t = [1 : 2 * L] / 8000;
    titles = {'Original Signal', 'Synthesized Signal (Speed Reduced)'};
    % sig_plot_t({[s; zeros(L, 1)], s_syn_v}, t, titles);
    sig_plot_t({[s; zeros(L, 1)], s_syn_v}, t, titles, './report/asserts/1_11_speed_reduced');

    % plot the signals in frequency domain
    titles = {'Original Signal Spectrum', 'Synthesized Signal Spectrum (Speed Reduced)'};
    % sig_plot_f({fft(s), fft(s_syn_v)}, 4000, titles);
    sig_plot_f({fft(s), fft(s_syn_v)}, 4000, titles, './report/asserts/1_11_speed_reduced');


    % (12)

    % calculate system with formant frequencies added by 150Hz 
    delta_formants = 150;
    angle = delta_formants * 2 * pi / 8000;
    rot_a = sys_rot_gen([1, -1.3789, 0.9506], angle);
    rot_a

    % plot the system
    % sys_plot(1, rot_a);
    sys_plot(1, rot_a, './report/asserts/1_12');


    % (13)

    % sound the synthesized signal (pitch increased)
    sig_sound(s_syn_t, 8000);

    % plot the signals in time domain
    t = [1 : L] / 8000;
    titles = {'Original Signal', 'Synthesized Signal (Pitch Increased)'};
    % sig_plot_t({s, s_syn_t}, t, titles);
    sig_plot_t({s, s_syn_t}, t, titles, './report/asserts/1_13_pitch_increased');

    % plot the signals in frequency domain
    titles = {'Original Signal Spectrum', 'Synthesized Signal Spectrum (Pitch Increased)'};
    % sig_plot_f({fft(s), fft(s_syn_t)}, 4000, titles);
    sig_plot_f({fft(s), fft(s_syn_t)}, 4000, titles, './report/asserts/1_13_pitch_increased');

    % 保存所有文件
    writespeech('./report/asserts/exc.pcm',exc);
    writespeech('./report/asserts/rec.pcm',s_rec);
    writespeech('./report/asserts/exc_syn.pcm',exc_syn);
    writespeech('./report/asserts/syn.pcm',s_syn);
    writespeech('./report/asserts/exc_syn_t.pcm',exc_syn_t);
    writespeech('./report/asserts/syn_t.pcm',s_syn_t);
    writespeech('./report/asserts/exc_syn_v.pcm',exc_syn_v);
    writespeech('./report/asserts/syn_v.pcm',s_syn_v);
return


function e = generate_e_addon(sr, N, seg_N)
    e = zeros(N, 1);
    idx = 1;
    while idx <= N
        e(idx) = 1;
        seg_idx = floor(idx / seg_N);
        PT = 80 + 5 * mod(seg_idx, 50);
        idx = idx + PT;
    end
return

function plot_signal(combined_signal, t, titles, save_path)
    max_y = max(cellfun(@max, cellfun(@abs, combined_signal, 'UniformOutput', false)));
    figure;
    for i = 1:3
        subplot(3, 1, i);
        plot(t, combined_signal{i});
        title(titles{i});
        ylabel('Amplitude');
        ylim([-max_y, max_y]);
    end
    xlabel('Time (s)');
    saveas(gcf, save_path);
return

% 从PCM文件中读入语音
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% 写语音到PCM文件中
function writespeech(filename,s)
    fid = fopen(filename, 'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% 计算一段语音的基音周期，不要求掌握
function PT = findpitch(s)
    [B, A] = butter(5, 700/4000);
    s = filter(B, A, s);
    R = zeros(143, 1);
    for k = 1:143
        R(k) = s(144:223)' * s(144-k : 223-k);
    end
    [R1, T1] = max(R(80:143));
    T1 = T1 + 79;
    R1 = R1 / (norm(s(144-T1 : 223-T1)) + 1);
    [R2, T2] = max(R(40:79));
    T2 = T2 + 39;
    R2 = R2 / (norm(s(144-T2 : 223-T2)) + 1);
    [R3, T3] = max(R(20:39));
    T3 = T3 + 19;
    R3 = R3 / (norm(s(144-T3 : 223-T3)) + 1);
    Top = T1;
    Rop = R1;
    if R2 >= 0.85 * Rop
        Rop = R2;
        Top = T2;
    end
    if R3 > 0.85 * Rop
        Rop = R3;
        Top = T3;
    end
    PT = Top;
return