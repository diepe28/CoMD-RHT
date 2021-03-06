/// \file
/// Wrappers for MPI functions.

#ifndef _PARALLEL_H_
#define _PARALLEL_H_

#include "mytype.h"
#include "RHT.h"

/// Structure for use with MPI_MINLOC and MPI_MAXLOC operations.
typedef struct RankReduceDataSt
{
   double val;
   int rank;
} RankReduceData;

typedef enum { NotReplicatedThread, ProducerThread, ConsumerThread } ExecutionThread;

extern _Thread_local int myRank;
extern _Thread_local int nRanks;
extern _Thread_local ExecutionThread currentThread;

/// Return total number of processors.
int getNRanks(void);

/// Return local rank.
int getMyRank(void);

/// Return non-zero if printing occurs from this rank.
int printRank(void);

/// Print a timestamp and message when all tasks arrive.
void timestampBarrier(const char* msg);

/// Wrapper for MPI_Init.
void initParallel(int *argc, char ***argv);

/// Wrapper for MPI_Finalize.
void destroyParallel(void);

/// Wrapper for MPI_Barrier(MPI_COMM_WORLD).
void barrierParallel(void);

/// Wrapper for MPI_Sendrecv.
int sendReceiveParallel(void* sendBuf, int sendLen, int dest,
                        void* recvBuf, int recvLen, int source);

int sendReceiveParallel_Producer(void* sendBuf, int sendLen, int dest,
                        void* recvBuf, int recvLen, int source);

int sendReceiveParallel_Consumer(void* sendBuf, int sendLen, int dest,
                        void* recvBuf, int recvLen, int source);

/// Wrapper for MPI_Allreduce integer sum.
void addIntParallel(int* sendBuf, int* recvBuf, int count);
void addIntParallel_Producer(int* sendBuf, int* recvBuf, int count);
void addIntParallel_Consumer(int* sendBuf, int* recvBuf, int count);

/// Wrapper for MPI_Allreduce real sum.
void addRealParallel(real_t* sendBuf, real_t* recvBuf, int count);
void addRealParallel_Producer(real_t* sendBuf, real_t* recvBuf, int count);
void addRealParallel_Consumer(real_t* sendBuf, real_t* recvBuf, int count);

/// Wrapper for MPI_Allreduce double sum.
void addDoubleParallel(double* sendBuf, double* recvBuf, int count);

/// Wrapper for MPI_Allreduce integer max.
void maxIntParallel(int* sendBuf, int* recvBuf, int count);

/// Wrapper for MPI_Allreduce double min with rank.
void minRankDoubleParallel(RankReduceData* sendBuf, RankReduceData* recvBuf, int count);

/// Wrapper for MPI_Allreduce double max with rank.
void maxRankDoubleParallel(RankReduceData* sendBuf, RankReduceData* recvBuf, int count);

/// Wrapper for MPI_Bcast
void bcastParallel(void* buf, int len, int root);

///  Return non-zero if code was built with MPI active.
int builtWithMpi(void);

#endif

