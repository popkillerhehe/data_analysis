function y = gammafilt(x)
%GAMMAFILT Filters input x and returns output y.
% filters in gamma frequency range 20-100. import eeg data from gh_debuffer
% example: 
% data = gammafilt(lfp.data);

persistent Hd;

if isempty(Hd)
    
    % The following code was used to design the filter coefficients:
    % % FIR Window Bandpass filter designed using the FIR1 function.
    %
    % % All frequency values are in Hz.
    % Fs = 2000;  % Sampling Frequency
    %
    % N    = 500;      % Order
    % Fc1  = 20;       % First Cutoff Frequency
    % Fc2  = 100;      % Second Cutoff Frequency
    % flag = 'scale';  % Sampling Flag
    % % Create the window vector for the design algorithm.
    % win = blackman(N+1);
    %
    % % Calculate the coefficients using the FIR1 function.
    % b  = fir1(N, [Fc1 Fc2]/(Fs/2), 'bandpass', win, flag);
    
    Hd = dsp.FIRFilter( ...
        'Numerator', [0 4.47361323994463e-09 3.37498851084184e-08 ...
        1.02518567518633e-07 2.0684397891209e-07 3.19416813649484e-07 ...
        3.8986877729405e-07 3.50563155133968e-07 1.27314261250414e-07 ...
        -3.4643710667198e-07 -1.11421127558919e-06 -2.18250067685876e-06 ...
        -3.51091388097386e-06 -5.00878530198624e-06 -6.53980481671982e-06 ...
        -7.93512638736327e-06 -9.01413835620904e-06 -9.61079130325914e-06 ...
        -9.60226731341556e-06 -8.93601219099285e-06 -7.6508801184505e-06 ...
        -5.88844321491159e-06 -3.89140996035759e-06 -1.98751177981636e-06 ...
        -5.59015776163661e-07 0 -6.65440383501505e-07 -2.81774683584401e-06 ...
        -6.57741008568607e-06 -1.18846916749359e-05 -1.84786971516018e-05 ...
        -2.58987065588665e-05 -3.35103954443568e-05 -4.05567684361046e-05 ...
        -4.62305400912717e-05 -4.97616892184604e-05 -5.05113607295878e-05 ...
        -4.80615492661151e-05 -4.22893608329688e-05 -3.3415294904769e-05 ...
        -2.2016964449605e-05 -9.00286469500889e-06 4.45505184502973e-06 ...
        1.70265379384516e-05 2.73577468328569e-05 3.422300760137e-05 ...
        3.66780228315271e-05 3.4197134062863e-05 2.67774436371009e-05 ...
        1.49947122002859e-05 -1.2540124822688e-19 -1.65483075261049e-05 ...
        -3.26156588082539e-05 -4.59770148037684e-05 -5.44414858777591e-05 ...
        -5.60946139286855e-05 -4.95331236907594e-05 -3.4065584010141e-05 ...
        -9.8538772889596e-06 2.20252555773761e-05 5.96122951373267e-05 ...
        0.000100195218219752 0.000140532152206446 0.000177150000575412 ...
        0.000206692983693992 0.000226287472121103 0.000233884997710092 ...
        0.000228544641204643 0.000210619481456488 0.000181819388491581 ...
        0.000145133633474735 0.000104610625388421 6.50072610057822e-05 ...
        3.1335344447051e-05 8.34565871464111e-06 -2.19838739474503e-20 ...
        8.9865194097533e-06 3.63331753243533e-05 8.11676426351324e-05 ...
        0.000140659927011123 0.000210167094660077 0.000283579424802977 ...
        0.000353845849586722 0.000413635965912472 0.000456078443862772 ...
        0.000475503393047318 0.000468110840102672 0.000432489954211624 ...
        0.000369924295228537 0.00028443656081768 0.0001825506406566 ...
        7.27770676730803e-05 -3.51425513828941e-05 -0.000131168884689829 ...
        -0.000205989979037744 -0.000252036905052911 -0.000264383220057884 ...
        -0.000241426883012619 -0.000185269598333906 -0.000101734853713809 ...
        2.13966447196646e-18 0.000108143505607678 0.000209347894885217 ...
        0.000289994653253536 0.000337588337702771 0.000342120606997946 ...
        0.000297261198881703 0.000201241999457113 5.73242725230408e-05 ...
        -0.000126224099299789 -0.000336667957195248 -0.000557835359796519 ...
        -0.000771561401946239 -0.000959420213854487 -0.00110458296808653 ...
        -0.00119361742064722 -0.00121804008565396 -0.0011754470504265 ...
        -0.00107008320595089 -0.000912759834111814 -0.000720092754963066 ...
        -0.000513101800362154 -0.000315280482176639 -0.000150305285555581 ...
        -3.96003653484073e-05 0 -4.1754160005458e-05 -0.000167100416176188 ...
        -0.000369579105214941 -0.000634201696078092 -0.000938500488913204 ...
        -0.00125439879202263 -0.00155075335947418 -0.00179634421373092 ...
        -0.00196302946370545 -0.00202875125321143 -0.00198007809751623 ...
        -0.0018140002247219 -0.00153875653665695 -0.00117355961267842 ...
        -0.000747191078509767 -0.000295553690582151 0.000141622640443949 ...
        0.000524627458574613 0.000817804609319492 0.000993373698837818 ...
        0.00103463849463174 0.000938225439441729 0.000715076779203983 ...
        0.000390036170493219 -1.58973869637611e-18 -0.000409247737801158 ...
        -0.000787259601233651 -0.00108383045552662 -0.00125411999897303 ...
        -0.00126348296118942 -0.00109150322365472 -0.000734784873273265 ...
        -0.000208158005155194 0.000455898464173268 0.00120964344662752 ...
        0.00199411431373273 0.00274449133448276 0.00339630634888962 ...
        0.00389190829636825 0.00418654481133722 0.00425342798447085 ...
        0.00408722551187475 0.00370555135573219 0.00314821202041677 ...
        0.00247417947677256 0.00175648946956172 0.00107548205760724 ...
        0.000510987372396362 0.00013419357236107 0 0.000140646929577662 ...
        0.000561321704205341 0.0012382751021066 0.00211975474258028 ...
        0.00312979424259537 0.004174612652247 0.00515110612197246 ...
        0.00595668053065337 0.00649950496360821 0.00670818118227507 ...
        0.00653983577032951 0.00598575262649521 0.00507386731249574 ...
        0.00386772536383374 0.00246183963029285 0.000973736385573969 ...
        -0.00046667779509387 -0.00172950092791551 -0.0026978274188981 ...
        -0.00328008748923318 -0.00342047941132452 -0.00310636797647341 ...
        -0.00237176760434165 -0.00129637148798586 2.64826918079984e-18 ...
        0.00136721485962263 0.0026381587343586 0.00364444694314426 ...
        0.00423309970712327 0.00428259665271922 0.0037167081031886 ...
        0.00251463628116849 0.00071628326291828 -0.00157812619166201 ...
        -0.0042143335886289 -0.00699595895152555 -0.00970119349122718 ...
        -0.0121029288350463 -0.0139905812634825 -0.0151916171712853 ...
        -0.0155907094303794 -0.0151445684734186 -0.0138907945017009 ...
        -0.011949568355229 -0.00951760191638376 -0.00685445442672515 ...
        -0.00426202922155255 -0.00205873220331143 -0.000550336321965695 0 ...
        -0.000600088884027714 -0.00244842336049462 -0.00553131247501462 ...
        -0.00971525267783576 -0.0147485018463825 -0.0202729376808312 ...
        -0.0258457407145228 -0.0309695797047735 -0.035129196565093 ...
        -0.037831659705115 -0.0386471376708626 -0.0372468814206759 ...
        -0.0334352145157652 -0.0271727137155026 -0.0185883921138199 ...
        -0.0079795254068053 0.00420127652006682 0.0173711340425262 ...
        0.0308524926490199 0.0439167681464193 0.0558328750796853 ...
        0.065917031238855 0.0735800777889094 0.078368703572732 0.079997403831711 ...
        0.078368703572732 0.0735800777889094 0.065917031238855 ...
        0.0558328750796853 0.0439167681464193 0.0308524926490199 ...
        0.0173711340425262 0.00420127652006682 -0.0079795254068053 ...
        -0.0185883921138199 -0.0271727137155026 -0.0334352145157652 ...
        -0.0372468814206759 -0.0386471376708626 -0.037831659705115 ...
        -0.035129196565093 -0.0309695797047735 -0.0258457407145228 ...
        -0.0202729376808312 -0.0147485018463825 -0.00971525267783576 ...
        -0.00553131247501462 -0.00244842336049462 -0.000600088884027714 0 ...
        -0.000550336321965695 -0.00205873220331143 -0.00426202922155255 ...
        -0.00685445442672515 -0.00951760191638376 -0.011949568355229 ...
        -0.0138907945017009 -0.0151445684734186 -0.0155907094303794 ...
        -0.0151916171712853 -0.0139905812634825 -0.0121029288350463 ...
        -0.00970119349122718 -0.00699595895152555 -0.0042143335886289 ...
        -0.00157812619166201 0.00071628326291828 0.00251463628116849 ...
        0.0037167081031886 0.00428259665271922 0.00423309970712327 ...
        0.00364444694314426 0.0026381587343586 0.00136721485962263 ...
        2.64826918079984e-18 -0.00129637148798586 -0.00237176760434165 ...
        -0.00310636797647341 -0.00342047941132452 -0.00328008748923318 ...
        -0.0026978274188981 -0.00172950092791551 -0.00046667779509387 ...
        0.000973736385573969 0.00246183963029285 0.00386772536383374 ...
        0.00507386731249574 0.00598575262649521 0.00653983577032951 ...
        0.00670818118227507 0.00649950496360821 0.00595668053065337 ...
        0.00515110612197246 0.004174612652247 0.00312979424259537 ...
        0.00211975474258028 0.0012382751021066 0.000561321704205341 ...
        0.000140646929577662 0 0.00013419357236107 0.000510987372396362 ...
        0.00107548205760724 0.00175648946956172 0.00247417947677256 ...
        0.00314821202041677 0.00370555135573219 0.00408722551187475 ...
        0.00425342798447085 0.00418654481133722 0.00389190829636825 ...
        0.00339630634888962 0.00274449133448276 0.00199411431373273 ...
        0.00120964344662752 0.000455898464173268 -0.000208158005155194 ...
        -0.000734784873273265 -0.00109150322365472 -0.00126348296118942 ...
        -0.00125411999897303 -0.00108383045552662 -0.000787259601233651 ...
        -0.000409247737801158 -1.58973869637611e-18 0.000390036170493219 ...
        0.000715076779203983 0.000938225439441729 0.00103463849463174 ...
        0.000993373698837818 0.000817804609319492 0.000524627458574613 ...
        0.000141622640443949 -0.000295553690582151 -0.000747191078509767 ...
        -0.00117355961267842 -0.00153875653665695 -0.0018140002247219 ...
        -0.00198007809751623 -0.00202875125321143 -0.00196302946370545 ...
        -0.00179634421373092 -0.00155075335947418 -0.00125439879202263 ...
        -0.000938500488913204 -0.000634201696078092 -0.000369579105214941 ...
        -0.000167100416176188 -4.1754160005458e-05 0 -3.96003653484073e-05 ...
        -0.000150305285555581 -0.000315280482176639 -0.000513101800362154 ...
        -0.000720092754963066 -0.000912759834111814 -0.00107008320595089 ...
        -0.0011754470504265 -0.00121804008565396 -0.00119361742064722 ...
        -0.00110458296808653 -0.000959420213854487 -0.000771561401946239 ...
        -0.000557835359796519 -0.000336667957195248 -0.000126224099299789 ...
        5.73242725230408e-05 0.000201241999457113 0.000297261198881703 ...
        0.000342120606997946 0.000337588337702771 0.000289994653253536 ...
        0.000209347894885217 0.000108143505607678 2.13966447196646e-18 ...
        -0.000101734853713809 -0.000185269598333906 -0.000241426883012619 ...
        -0.000264383220057884 -0.000252036905052911 -0.000205989979037744 ...
        -0.000131168884689829 -3.51425513828941e-05 7.27770676730803e-05 ...
        0.0001825506406566 0.00028443656081768 0.000369924295228537 ...
        0.000432489954211624 0.000468110840102672 0.000475503393047318 ...
        0.000456078443862772 0.000413635965912472 0.000353845849586722 ...
        0.000283579424802977 0.000210167094660077 0.000140659927011123 ...
        8.11676426351324e-05 3.63331753243533e-05 8.9865194097533e-06 ...
        -2.19838739474503e-20 8.34565871464111e-06 3.1335344447051e-05 ...
        6.50072610057822e-05 0.000104610625388421 0.000145133633474735 ...
        0.000181819388491581 0.000210619481456488 0.000228544641204643 ...
        0.000233884997710092 0.000226287472121103 0.000206692983693992 ...
        0.000177150000575412 0.000140532152206446 0.000100195218219752 ...
        5.96122951373267e-05 2.20252555773761e-05 -9.8538772889596e-06 ...
        -3.4065584010141e-05 -4.95331236907594e-05 -5.60946139286855e-05 ...
        -5.44414858777591e-05 -4.59770148037684e-05 -3.26156588082539e-05 ...
        -1.65483075261049e-05 -1.2540124822688e-19 1.49947122002859e-05 ...
        2.67774436371009e-05 3.4197134062863e-05 3.66780228315271e-05 ...
        3.422300760137e-05 2.73577468328569e-05 1.70265379384516e-05 ...
        4.45505184502973e-06 -9.00286469500889e-06 -2.2016964449605e-05 ...
        -3.3415294904769e-05 -4.22893608329688e-05 -4.80615492661151e-05 ...
        -5.05113607295878e-05 -4.97616892184604e-05 -4.62305400912717e-05 ...
        -4.05567684361046e-05 -3.35103954443568e-05 -2.58987065588665e-05 ...
        -1.84786971516018e-05 -1.18846916749359e-05 -6.57741008568607e-06 ...
        -2.81774683584401e-06 -6.65440383501505e-07 0 -5.59015776163661e-07 ...
        -1.98751177981636e-06 -3.89140996035759e-06 -5.88844321491159e-06 ...
        -7.6508801184505e-06 -8.93601219099285e-06 -9.60226731341556e-06 ...
        -9.61079130325914e-06 -9.01413835620904e-06 -7.93512638736327e-06 ...
        -6.53980481671982e-06 -5.00878530198624e-06 -3.51091388097386e-06 ...
        -2.18250067685876e-06 -1.11421127558919e-06 -3.4643710667198e-07 ...
        1.27314261250414e-07 3.50563155133968e-07 3.8986877729405e-07 ...
        3.19416813649484e-07 2.0684397891209e-07 1.02518567518633e-07 ...
        3.37498851084184e-08 4.47361323994463e-09 0]);
end

y = step(Hd,x);


% [EOF]
