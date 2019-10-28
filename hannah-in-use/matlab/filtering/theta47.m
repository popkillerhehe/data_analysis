function y = theta47(x)
%THETA47 Filters input x and returns output y.

% MATLAB Code
% Generated by MATLAB(R) 9.5 and DSP System Toolbox 9.7.
% Generated on: 21-May-2019 17:29:59

%#codegen

% To generate C/C++ code from this function use the codegen command. Type
% 'help codegen' for more information.

persistent Hd;

if isempty(Hd)

    % The following code was used to design the filter coefficients:
    % % FIR Window Bandpass filter designed using the FIR1 function.
    %
    % % All frequency values are in Hz.
    % Fs = 2000;  % Sampling Frequency
    %
    % N    = 200;      % Order
    % Fc1  = 4;        % First Cutoff Frequency
    % Fc2  = 7;        % Second Cutoff Frequency
    % flag = 'scale';  % Sampling Flag
    % % Create the window vector for the design algorithm.
    % win = blackman(N+1);
    %
    % % Calculate the coefficients using the FIR1 function.
    % b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);

    Hd = dsp.FIRFilter( ...
        'Numerator', [0 -1.86029033983871e-07 -6.53820539349917e-07 ...
        -1.26763582149794e-06 -1.89066691208034e-06 -2.38419209719175e-06 ...
        -2.60674013562085e-06 -2.41327333888625e-06 -1.6543995800965e-06 ...
        -1.75623116432745e-07 2.18335614866873e-06 5.58928567113047e-06 ...
        1.02159366534302e-05 1.62446054035136e-05 2.38645317988244e-05 ...
        3.32732275954272e-05 4.46767079880142e-05 5.82896205471564e-05 ...
        7.43352664306325e-05 9.30455095807731e-05 0.00011466057047396 ...
        0.000139428701875886 0.00016760574497075 0.000199454565168035 ...
        0.00023524436784029 0.000275249895202935 0.000319750506505793 ...
        0.000369029144659087 0.000423371193357421 0.000483063229687046 ...
        0.000548391678098001 0.000619641372487117 0.000697094033964175 ...
        0.000781026672655683 0.000871709922633155 0.000969406319729996 ...
        0.00107436853262804 0.00118683755814687 0.00130704089215192 ...
        0.00143519068790732 0.00157148191403305 0.00171609052448039 ...
        0.00186917165311282 0.00203085784556907 0.00220125734109039 ...
        0.00238045241691415 0.00256849780767059 0.0027654192119694 ...
        0.00297121189802882 0.00318583941978367 0.00340923245441213 ...
        0.00364128777164729 0.00388186734459091 0.00413079761102798 ...
        0.00438786889345518 0.00465283498518897 0.00492541290901482 ...
        0.00520528285388379 0.00549208829416142 0.00578543629489345 ...
        0.00608489800547953 0.00639000934304623 0.0067002718656911 ...
        0.00701515383463836 0.0073340914632091 0.00765649034937404 ...
        0.00798172708753075 0.00830915105403732 0.00863808635994782 ...
        0.00896783396333934 0.0092976739326009 0.00962686785107989 ...
        0.00995466135255664 0.0102802867761491 0.0106029659284427 ...
        0.0109219129399022 0.0112363372019526 0.0115454463705295 ...
        0.0118484494213868 0.0121445597420247 0.012432998244766 ...
        0.0127129964852547 0.0129837997705019 0.0132446702405333 ...
        0.0134948899077278 0.0137337636380592 0.0139606220586702 ...
        0.0141748243765186 0.0143757610932369 0.0145628566018349 ...
        0.0147355716514524 0.0148934056670244 0.0150358989114612 ...
        0.0151626344787556 0.0152732401073097 0.015367389803723 ...
        0.0154448052682827 0.0155052571144605 0.015548565875819 ...
        0.0155746027948776 0.0155832903896638 0.0155746027948776 ...
        0.015548565875819 0.0155052571144605 0.0154448052682827 ...
        0.015367389803723 0.0152732401073097 0.0151626344787556 ...
        0.0150358989114612 0.0148934056670244 0.0147355716514524 ...
        0.0145628566018349 0.0143757610932369 0.0141748243765186 ...
        0.0139606220586702 0.0137337636380592 0.0134948899077278 ...
        0.0132446702405333 0.0129837997705019 0.0127129964852547 ...
        0.012432998244766 0.0121445597420247 0.0118484494213868 ...
        0.0115454463705295 0.0112363372019526 0.0109219129399022 ...
        0.0106029659284427 0.0102802867761491 0.00995466135255664 ...
        0.00962686785107989 0.0092976739326009 0.00896783396333934 ...
        0.00863808635994782 0.00830915105403732 0.00798172708753075 ...
        0.00765649034937404 0.0073340914632091 0.00701515383463836 ...
        0.0067002718656911 0.00639000934304623 0.00608489800547953 ...
        0.00578543629489345 0.00549208829416142 0.00520528285388379 ...
        0.00492541290901482 0.00465283498518897 0.00438786889345518 ...
        0.00413079761102798 0.00388186734459091 0.00364128777164729 ...
        0.00340923245441213 0.00318583941978367 0.00297121189802882 ...
        0.0027654192119694 0.00256849780767059 0.00238045241691415 ...
        0.00220125734109039 0.00203085784556907 0.00186917165311282 ...
        0.00171609052448039 0.00157148191403305 0.00143519068790732 ...
        0.00130704089215192 0.00118683755814687 0.00107436853262804 ...
        0.000969406319729996 0.000871709922633155 0.000781026672655683 ...
        0.000697094033964175 0.000619641372487117 0.000548391678098001 ...
        0.000483063229687046 0.000423371193357421 0.000369029144659087 ...
        0.000319750506505793 0.000275249895202935 0.00023524436784029 ...
        0.000199454565168035 0.00016760574497075 0.000139428701875886 ...
        0.00011466057047396 9.30455095807731e-05 7.43352664306325e-05 ...
        5.82896205471564e-05 4.46767079880142e-05 3.32732275954272e-05 ...
        2.38645317988244e-05 1.62446054035136e-05 1.02159366534302e-05 ...
        5.58928567113047e-06 2.18335614866873e-06 -1.75623116432745e-07 ...
        -1.6543995800965e-06 -2.41327333888625e-06 -2.60674013562085e-06 ...
        -2.38419209719175e-06 -1.89066691208034e-06 -1.26763582149794e-06 ...
        -6.53820539349917e-07 -1.86029033983871e-07 0]);
end

y = step(Hd,(x));
delay = mean(grpdelay(Hd));

y(1:delay) = [];


% [EOF]