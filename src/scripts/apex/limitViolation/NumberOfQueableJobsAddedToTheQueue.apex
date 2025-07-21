for (Integer i = 0; i < 51; i++) {
    System.enqueueJob(new QueueableJobsLimitViolation());
}
