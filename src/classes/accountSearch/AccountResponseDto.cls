public with sharing class AccountResponseDto {
    @AuraEnabled
    public List<Account> records;
    @AuraEnabled
    public Integer totalSize;

    public AccountResponseDto(List<Account> records, Integer totalSize) {
        this.records = records;
        this.totalSize = totalSize;
    }
}