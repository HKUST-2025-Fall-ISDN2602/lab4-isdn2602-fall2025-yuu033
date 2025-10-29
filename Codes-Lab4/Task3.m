% Channel Coding
% Task 3

clear all; close all; clc;
addpath("library_p\");

% You may revise the dictionary, but it will not affect the channel coding%
  dict = { [0 0 0 0 1 0 0 1],[1], [0 0 1], [ 0 1 0], [0 1 1], [0 0 0 1 1],...
         [0 0 0 0 1 1], [0 0 0 1 0], [0 0 0 0 1 0 1], [0 0 0 0 1 0 0 0],[0 0 0 0 0]};
    
% Load the input image
lorem_img = imread('lorem_img.png');

% run-length encode
run_length_code = runlength_encode(lorem_img);
% convert the binary array into an decimal array of run lengths
runs = bin2decArray(run_length_code);

% Use the dictionary to encode the run lengths
huffman = huffman_encode_dict(runs, dict);
huffman = huffman(1:end-mod(length(huffman),4));
size_huffman = length(huffman);

distance_list = [1:50]; % list of transmission distances
num_dist = length(distance_list);

BER_no_ecc = zeros(1,num_dist); % initialize storage arrays
BER_rep_ecc = zeros(1,num_dist);
BER_blk_ecc = zeros(1,num_dist);

rep = 3; % number of repetitions
bs_rep_enc = rep_encode_bs(huffman,rep); % repetition code encoder
bs_blk_enc = blk_encode_bs(huffman); % (n,k) block code encoder
% encode bitstream with error correction

disp("Please wait ... ");
% loop over different transmission distances
for i = 1:num_dist
    distance = distance_list(i);
    bs_no_ecc = binary_channel(huffman,distance); % simulate the transmission over binary channel
    bs_rep_out = binary_channel(bs_rep_enc,distance);
    bs_blk_out = binary_channel(bs_blk_enc,distance);
    bs_rep_dec = rep_decode_bs(bs_rep_out,rep); % repetition code deocder
    bs_blk_dec = blk_decode_bs(bs_blk_out); % (n,k) block code deocder
    BER_no_ecc(i) = compute_BER(huffman,bs_no_ecc); % compute bit error rate
    BER_rep_ecc(i) = compute_BER(huffman,bs_rep_dec);
    BER_blk_ecc(i) = compute_BER(huffman,bs_blk_dec);
end

% display the results, do not modify the code below
figure(1);clf;
plot(distance_list,BER_no_ecc,'r','LineWidth',2);
hold on;
plot(distance_list,BER_rep_ecc,'bx','LineWidth',2);
hold on;
plot(distance_list,BER_blk_ecc,'gx','LineWidth',2);
hold off;
axis([0 50 0 0.5]);
legend('BER\_no\_ecc','BER\_rep\_ecc','BER\_blk\_ecc','Location','southeast');
title('BER vs. Transmission Distance');
xlabel('Transmission Distance');
ylabel('BER');
grid;

test_blk_decoder
