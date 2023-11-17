#include "jailbreakd.h"

void kreadbuf(uint64_t kaddr, void *output, size_t size) {
  uint64_t endAddr = kaddr + size;
  uint32_t outputOffset = 0;
  unsigned char *outputBytes = (unsigned char *)output;

  for (uint64_t curAddr = kaddr; curAddr < endAddr; curAddr += 4) {
    uint32_t k = jbdKread32(curAddr);

    unsigned char *kb = (unsigned char *)&k;
    for (int i = 0; i < 4; i++) {
      if (outputOffset == size)
        break;
      outputBytes[outputOffset] = kb[i];
      outputOffset++;
    }
    if (outputOffset == size)
      break;
  }
}

void kwritebuf(uint64_t kaddr, void *input, size_t size) {
  uint64_t endAddr = kaddr + size;
  uint32_t inputOffset = 0;
  unsigned char *inputBytes = (unsigned char *)input;

  for (uint64_t curAddr = kaddr; curAddr < endAddr; curAddr += 4) {
    uint32_t toWrite = 0;
    int bc = 4;

    uint64_t remainingBytes = endAddr - curAddr;
    if (remainingBytes < 4) {
      toWrite = jbdKread32(curAddr);
      bc = (int)remainingBytes;
    }

    unsigned char *wb = (unsigned char *)&toWrite;
    for (int i = 0; i < bc; i++) {
      wb[i] = inputBytes[inputOffset];
      inputOffset++;
    }

    jbdKwrite32(curAddr, toWrite);
  }
}

int jbdrw_kread(uint64_t from, void *to, size_t len) {
  kreadbuf(from, to, len);
  return 0;
}

int jbdrw_kwrite(void *from, uint64_t to, size_t len) {
  kwritebuf(to, from, len);
  return 0;
}

int jbdrw_kalloc(uint64_t *addr, size_t size) {
  uint64_t allocated_kmem = 0;
  allocated_kmem = jbdKalloc(size);
  *addr = allocated_kmem;
  return 0;
}

int jbdrw_kfree(uint64_t addr, size_t size) {
  jbdKfree(addr, size);
  return 0;
}

int jbdrw_kcall(uint64_t func, size_t argc, const uint64_t *argv,
                uint64_t *ret) {
  uint64_t kcallret = jbdKcall(func, argc, argv);
  *ret = kcallret;

  return 0;
}