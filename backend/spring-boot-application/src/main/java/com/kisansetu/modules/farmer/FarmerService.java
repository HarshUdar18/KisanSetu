package com.kisansetu.modules.farmer;

import com.kisansetu.common.exception.ResourceNotFoundException;
import com.kisansetu.modules.farmer.entity.FarmerProfile;
import com.kisansetu.modules.farmer.repository.FarmerListingRepository;
import com.kisansetu.modules.farmer.repository.FarmerProfileRepository;
import com.kisansetu.modules.operations.repository.CollectionRecordRepository;
import com.kisansetu.modules.settlement.entity.Settlement;
import com.kisansetu.modules.settlement.repository.SettlementRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Map;
import java.util.UUID;

@Service
public class FarmerService {

    private final FarmerProfileRepository farmerProfileRepository;
    private final FarmerListingRepository listingRepository;
    private final CollectionRecordRepository collectionRepository;
    private final SettlementRepository settlementRepository;

    public FarmerService(FarmerProfileRepository farmerProfileRepository,
                         FarmerListingRepository listingRepository,
                         CollectionRecordRepository collectionRepository,
                         SettlementRepository settlementRepository) {
        this.farmerProfileRepository = farmerProfileRepository;
        this.listingRepository = listingRepository;
        this.collectionRepository = collectionRepository;
        this.settlementRepository = settlementRepository;
    }

    @Transactional(readOnly = true)
    public FarmerProfile getProfileByUserId(UUID userId) {
        return farmerProfileRepository.findByUserId(userId)
                .orElseThrow(() -> new ResourceNotFoundException("FarmerProfile", "userId", userId));
    }

    @Transactional
    public FarmerProfile updateProfile(UUID userId, Map<String, Object> body) {
        FarmerProfile profile = getProfileByUserId(userId);
        if (body.get("fullName") != null) profile.setFullName(body.get("fullName").toString());
        if (body.get("village") != null) profile.setVillage(body.get("village").toString());
        if (body.get("district") != null) profile.setDistrict(body.get("district").toString());
        if (body.get("state") != null) profile.setState(body.get("state").toString());
        if (body.get("pincode") != null) profile.setPincode(body.get("pincode").toString());
        if (body.get("primaryCropCategory") != null) profile.setPrimaryCropCategory(body.get("primaryCropCategory").toString());
        if (body.get("farmName") != null) profile.setFarmName(body.get("farmName").toString());
        if (body.get("landArea") != null) profile.setLandArea(new BigDecimal(body.get("landArea").toString()));
        if (body.get("landUnit") != null) profile.setLandUnit(body.get("landUnit").toString());
        if (body.get("soilType") != null) profile.setSoilType(body.get("soilType").toString());
        if (body.get("irrigationType") != null) profile.setIrrigationType(body.get("irrigationType").toString());
        if (body.get("farmingExperienceYears") != null) profile.setFarmingExperienceYears(Integer.parseInt(body.get("farmingExperienceYears").toString()));
        if (body.get("latitude") != null) profile.setLatitude(new BigDecimal(body.get("latitude").toString()));
        if (body.get("longitude") != null) profile.setLongitude(new BigDecimal(body.get("longitude").toString()));
        return farmerProfileRepository.save(profile);
    }

    @Transactional(readOnly = true)
    public Map<String, Object> getDashboardSummary(UUID userId) {
        FarmerProfile profile = getProfileByUserId(userId);
        long activeListings = listingRepository.findByFarmerIdOrderByCreatedAtDesc(userId).stream()
                .filter(l -> Boolean.TRUE.equals(l.getIsAvailable()) && "ACTIVE".equalsIgnoreCase(l.getStatus())).count();
        long pendingCollections = collectionRepository.findByFarmerIdOrderByScheduledDateDesc(userId).stream()
                .filter(c -> "SCHEDULED".equalsIgnoreCase(c.getStatus())).count();
        BigDecimal walletBalance = settlementRepository.findByFarmerIdOrderByCreatedAtDesc(userId).stream()
                .filter(s -> "PENDING".equalsIgnoreCase(s.getStatus()) || "AUTHORIZED".equalsIgnoreCase(s.getStatus()))
                .map(Settlement::getNetAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        return Map.of(
                "farmerName", profile.getFullName(),
                "village", profile.getVillage() != null ? profile.getVillage() : "N/A",
                "district", profile.getDistrict() != null ? profile.getDistrict() : "N/A",
                "primaryCrop", profile.getPrimaryCropCategory() != null ? profile.getPrimaryCropCategory() : "General",
                "activeListingsCount", activeListings,
                "pendingCollectionsCount", pendingCollections,
                "walletBalance", walletBalance,
                "soilType", profile.getSoilType() != null ? profile.getSoilType() : "",
                "irrigationType", profile.getIrrigationType() != null ? profile.getIrrigationType() : ""
        );
    }
}
