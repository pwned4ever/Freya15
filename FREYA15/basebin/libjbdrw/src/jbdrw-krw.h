int jbdrw_kread(uint64_t from, void *to, size_t len);

int jbdrw_kwrite(void *from, uint64_t to, size_t len);


int jbdrw_kalloc(uint64_t *addr, size_t size);

int jbdrw_kfree(uint64_t addr, size_t size);

int jbdrw_kcall(uint64_t func, size_t argc, const uint64_t *argv,
                uint64_t *ret);