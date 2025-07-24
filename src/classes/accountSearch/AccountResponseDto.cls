public with sharing class AccountResponseDto {
    public List<Account> records;
    public Integer totalSize;

    public AccountResponseDto(List<Account> records, Integer totalSize) {
        this.records = records;
        this.totalSize = totalSize;
    }
}