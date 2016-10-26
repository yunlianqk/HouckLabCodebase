function [ Spec_peak ] = Spec_peak_detect( Spec_scan, delta )
    [r,c] = size(Spec_scan);
    Spec_peak = nan(r,c);
    for row = 1:r
        clear locs
        % add a minus sign to flip the peak and dip
%         [~,locs] = findpeaks(-Spec_scan(row,:),'Threshold',10)
%         max_v = max(Spec_scan(row,:));
%         min_v = min(Spec_scan(row,:));
%         D = max_v-min_v
        [~, mintab] = peakdet(Spec_scan(row,:),delta);
        locs = mintab(:,1);
        Spec_peak(row,locs) = 1;
    end
    figure(123)
    subplot(2,1,1);
    imagesc(Spec_scan)
    subplot(2,1,2);
    imagesc(Spec_peak)
end

