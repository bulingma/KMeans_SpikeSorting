load ps5_data.mat

SAMPLE_LENGTH = 31;
PREV_SAMPLES = 10;

AFTER_SAMPLES = SAMPLE_LENGTH - PREV_SAMPLES - 1;

x = RealWaveform;
f_0 = 30000; % sampling rate of waveform (Hz)
f_stop = 250; % stop frequency (Hz)
f_Nyquist = f_0/2; % the Nyquist limit
n = length(x);
f_all = linspace(-f_Nyquist,f_Nyquist,n);
desired_response = ones(n,1);
desired_response(abs(f_all)<=f_stop) = 0;
x_filtered = real(fftshift(ifft(fft(x.*fftshift(desired_response)))));

subplot(3,1,1);
plot(x_filtered);
hold on
V_th  = ones(size(x_filtered,1),1).*250;
plot(V_th,'k');

x_filtered_shifted = [0; x_filtered(1:size(x_filtered, 1) -1)];
above_th_locs = find((x_filtered > V_th) & (x_filtered_shifted < V_th));
snippets = zeros(SAMPLE_LENGTH, size(above_th_locs, 1));
for i=1:size(above_th_locs,1)
    snippets(:,i) = x_filtered(above_th_locs(i)-PREV_SAMPLES:above_th_locs(i)+AFTER_SAMPLES);
end
save snippets.mat snippets
subplot(3,1,2);
plot(V_th(1:SAMPLE_LENGTH),'k');
hold on
for i=1:size(above_th_locs,1)
    plot(snippets(:,i));
    hold on
end

mean_vectors = InitTwoClusters_1;

NUM_OF_CLUSTERS = size(mean_vectors, 2);
DIMENSIONALITY = size(mean_vectors, 1);
NUM_OF_POINTS = size(snippets, 2);

r = zeros(NUM_OF_CLUSTERS, NUM_OF_POINTS);

J = [];

iter_count = 0;
while(1)
    iter_count = iter_count + 1;
    % E Step
    dist = pdist2(mean_vectors', snippets');
    for j=1:NUM_OF_CLUSTERS
        r(j, :) = dist(j, :) == min(dist);
    end


    % M Step
    for i=1:NUM_OF_CLUSTERS
        numer = zeros(DIMENSIONALITY, 1);
        denom = 0;
        for j=1:NUM_OF_POINTS
            numer = numer + snippets(:, j).*r(i,j);
            denom = denom + r(i, j);
        end
        mean_vectors(:, i) = numer ./ denom;
    end

    % Computing J
    J_iter = 0;
    for i=1:NUM_OF_POINTS
        for j=1:NUM_OF_CLUSTERS
            J_iter = J_iter + norm(snippets(:,i) - mean_vectors(:,j)) .* r(j, i);
        end
    end
    J = [J;J_iter];
    if iter_count ~= 1 && (J_iter == J(iter_count - 1))
        break;
    end
   
end

for i=1:NUM_OF_CLUSTERS
    plot(mean_vectors(:, i), 'r');
    hold on
end

subplot(3,1,3);
plot(J);