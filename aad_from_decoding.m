function results = aad_from_decoding(params)
    aad_construct_decoders(params);

    if params.avg_decoders
        aad_avg_decoders(params);
    end

    % Apply the decoders to their corresponding trial, save the result.
    % This function will also need to take into account the parameters that
    % were used to construct the decoders.

    aad_apply_decoders(params);


    % Compute correlations with both audio envelopes (attended and unattended)
    % to perform classification. [R,P]=corrcoef(...) also returns P, a matrix of p-values for testing the hypothesis of no correlation.

    aad_evaluate(params);


    % Visualize the results... Maybe use R for this? If so, we first have to
    % put the results in a .csv file.

    % Results aggregated per experiment (over all subjects and conditions)
    results = aad_aggregate_results(params); % load all results, then average.
end