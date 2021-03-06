/// \file
/// Wrappers for MPI functions.  This should be the only compilation 
/// unit in the code that directly calls MPI functions.  To build a pure
/// serial version of the code with no MPI, do not define DO_MPI.  If
/// DO_MPI is not defined then all MPI functionality is replaced with
/// equivalent single task behavior.

#include "parallel.h"
#include "RHT.h"

#ifdef DO_MPI
#include <mpi.h>
#endif

#include <stdio.h>
#include <time.h>
#include <string.h>
#include <assert.h>

_Thread_local int myRank = 0;
_Thread_local int nRanks = 1;
_Thread_local ExecutionThread currentThread = ProducerThread;

#ifdef DO_MPI
#ifdef SINGLE
#define REAL_MPI_TYPE MPI_FLOAT
#else
#define REAL_MPI_TYPE MPI_DOUBLE
#endif

#endif

int getNRanks()
{
   return nRanks;
}

int getMyRank() {
    return myRank;
}

/// \details
/// For now this is just a check for rank 0 but in principle it could be
/// more complex.  It is also possible to suppress practically all
/// output by causing this function to return 0 for all ranks.
int printRank() {
    if (myRank == 0 && currentThread != ConsumerThread) return 1;
    return 0;
}

void timestampBarrier(const char* msg) {
    barrierParallel();
    if (!printRank())
        return;
    time_t t = time(NULL);
    char *timeString = ctime(&t);
    timeString[24] = '\0'; // clobber newline

    fprintf(screenOut, "%s: %s\n", timeString, msg);
    fflush(screenOut);
}

void initParallel(int* argc, char*** argv) {
#ifdef DO_MPI
   MPI_Init(argc, argv);
   MPI_Comm_rank(MPI_COMM_WORLD, &myRank);
   MPI_Comm_size(MPI_COMM_WORLD, &nRanks);
#endif
}

void destroyParallel() {
#ifdef DO_MPI
    MPI_Finalize();
#endif
}

void barrierParallel() {
#ifdef DO_MPI
    if(currentThread == ConsumerThread){
        printf("\n\n\n HERE IS A PROBLEM  IN BARRIER PARALLEL \n\n\n");
        exit(34);
    }
    MPI_Barrier(MPI_COMM_WORLD);
#endif
}

/// \param [in]  sendBuf Data to send.
/// \param [in]  sendLen Number of bytes to send.
/// \param [in]  dest    Rank in MPI_COMM_WORLD where data will be sent.
/// \param [out] recvBuf Received data.
/// \param [in]  recvLen Maximum number of bytes to receive.
/// \param [in]  source  Rank in MPI_COMM_WORLD from which to receive.
/// \return Number of bytes received.
int sendReceiveParallel(void* sendBuf, int sendLen, int dest,
                        void* recvBuf, int recvLen, int source) {
#ifdef DO_MPI
    int bytesReceived;
    MPI_Status status;
    MPI_Sendrecv(sendBuf, sendLen, MPI_BYTE, dest, 0,
                 recvBuf, recvLen, MPI_BYTE, source, 0,
                 MPI_COMM_WORLD, &status);
    MPI_Get_count(&status, MPI_BYTE, &bytesReceived);

    return bytesReceived;
#else
    assert(source == dest);
    memcpy(recvBuf, sendBuf, sendLen);

    return sendLen;
#endif
}

int sendReceiveParallel_Producer(void* sendBuf, int sendLen, int dest,
                        void* recvBuf, int recvLen, int source) {
#ifdef DO_MPI
    int bytesReceived;
        MPI_Status status;
    RHT_Produce_Volatile(sendLen);
    MPI_Sendrecv(sendBuf, sendLen, MPI_BYTE, dest, 0,
                 recvBuf, recvLen, MPI_BYTE, source, 0,
                 MPI_COMM_WORLD, &status);
    MPI_Get_count(&status, MPI_BYTE, &bytesReceived);

    //dperez, replication must send data to consumer
    char * buffer = (char*) recvBuf;
    for(int i = 0; i < recvLen; i++){
        RHT_Produce_NoCheck((double)buffer[i]);
    }
    RHT_Produce_NoCheck(bytesReceived);

    return bytesReceived;
#else
    assert(source == dest);
    RHT_Produce_Volatile(sendLen);
    memcpy(recvBuf, sendBuf, sendLen);

    return sendLen;
#endif
}

int sendReceiveParallel_Consumer(void* sendBuf, int sendLen, int dest,
                        void* recvBuf, int recvLen, int source) {
#ifdef DO_MPI
    int bytesReceived;
//    MPI_Status status;
//    MPI_Sendrecv(sendBuf, sendLen, MPI_BYTE, dest, 0,
//                 recvBuf, recvLen, MPI_BYTE, source, 0,
//                 MPI_COMM_WORLD, &status);
//    MPI_Get_count(&status, MPI_BYTE, &bytesReceived);
    //dperez, replication must send data to consumer
    RHT_Consume_Volatile((double)sendLen);
    char * buffer = (char*) recvBuf;
    for(int i = 0; i < recvLen; i++){
        buffer[i] = (char) RHT_Consume();
    }
    bytesReceived = RHT_Consume();

    return bytesReceived;
#else
    assert(source == dest);
    RHT_Consume_Volatile((double)sendLen);
    memcpy(recvBuf, sendBuf, sendLen);

    return sendLen;
#endif
}

void addIntParallel(int* sendBuf, int* recvBuf, int count) {
#ifdef DO_MPI
//    if(currentThread == ConsumerThread){
//        printf("\n\n\nHERE IS A PROBLEM  IN ADD INT PARALLEL \n\n\n");
//        exit(34);
//    }

    if(currentThread == ProducerThread){
        RHT_Produce_Volatile(count);
    }else if(currentThread == ConsumerThread){
        RHT_Consume_Volatile(count);
    }

    MPI_Allreduce(sendBuf, recvBuf, count, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
#else
    for (int ii=0; ii<count; ++ii)
       recvBuf[ii] = sendBuf[ii];
#endif
}

void addIntParallel_Producer(int* sendBuf, int* recvBuf, int count) {
#ifdef DO_MPI
    RHT_Produce_Volatile(count);
    MPI_Allreduce(sendBuf, recvBuf, count, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    // dperez, send data to consumer
    for(int i = 0; i < count; i++){
        RHT_Produce_NoCheck(recvBuf[i]);
    }
#else
    for (int ii=0; ii<count; ++ii)
       recvBuf[ii] = sendBuf[ii];
#endif
}

void addIntParallel_Consumer(int* sendBuf, int* recvBuf, int count) {
#ifdef DO_MPI
    //MPI_Allreduce(sendBuf, recvBuf, count, MPI_INT, MPI_SUM, MPI_COMM_WORLD);
    // dperez, get data from producer
    RHT_Consume_Volatile(count);
    for(int i = 0; i < count; i++){
        recvBuf[i] = RHT_Consume();
    }
#else
    for (int ii=0; ii<count; ++ii)
       recvBuf[ii] = sendBuf[ii];
#endif
}

void addRealParallel(real_t* sendBuf, real_t* recvBuf, int count) {
#ifdef DO_MPI
    if(currentThread == ConsumerThread){
        printf("\n\n\nHERE IS A PROBLEM  IN ADD REAL PARALLEL \n\n\n");
        exit(34);
    }
    MPI_Allreduce(sendBuf, recvBuf, count, REAL_MPI_TYPE, MPI_SUM, MPI_COMM_WORLD);
#else
    for (int ii=0; ii<count; ++ii)
       recvBuf[ii] = sendBuf[ii];
#endif
}

void addRealParallel_Producer(real_t* sendBuf, real_t* recvBuf, int count) {
#ifdef DO_MPI
    RHT_Produce_Volatile(count);
    MPI_Allreduce(sendBuf, recvBuf, count, REAL_MPI_TYPE, MPI_SUM, MPI_COMM_WORLD);

    // dperez, send data to consumer
    for(int i = 0; i < count; i++){
        RHT_Produce_NoCheck(recvBuf[i]);
    }
#else
    for (int ii=0; ii<count; ++ii)
        recvBuf[ii] = sendBuf[ii];
#endif
}

void addRealParallel_Consumer(real_t* sendBuf, real_t* recvBuf, int count) {
#ifdef DO_MPI
    RHT_Consume_Volatile(count);
    //MPI_Allreduce(sendBuf, recvBuf, count, REAL_MPI_TYPE, MPI_SUM, MPI_COMM_WORLD);
    // dperez, get data from producer
    for(int i = 0; i < count; i++){
        recvBuf[i] = RHT_Consume();
    }
#else
    for (int ii=0; ii<count; ++ii)
        recvBuf[ii] = sendBuf[ii];
#endif
}

void addDoubleParallel(double* sendBuf, double* recvBuf, int count) {
#ifdef DO_MPI
    if(currentThread == ConsumerThread){
        printf("\n\n\nHERE IS A PROBLEM  IN ADD DOUBLE PARALLEL \n\n\n");
        exit(34);
    }
    MPI_Allreduce(sendBuf, recvBuf, count, MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
#else
    for (int ii=0; ii<count; ++ii)
       recvBuf[ii] = sendBuf[ii];
#endif
}

void maxIntParallel(int* sendBuf, int* recvBuf, int count) {
#ifdef DO_MPI
    if(currentThread == ConsumerThread){
        printf("\n\n\nHERE IS A MAX INT IN ADD INT PARALLEL \n\n\n");
        exit(34);
    }
    MPI_Allreduce(sendBuf, recvBuf, count, MPI_INT, MPI_MAX, MPI_COMM_WORLD);
#else
    for (int ii=0; ii<count; ++ii)
       recvBuf[ii] = sendBuf[ii];
#endif
}


void minRankDoubleParallel(RankReduceData* sendBuf, RankReduceData* recvBuf, int count) {
#ifdef DO_MPI
    if(currentThread == ConsumerThread){
        printf("\n\n\nHERE IS A PROBLEM IN MIN RANK DOUBLE PARALLEL \n\n\n");
        exit(34);
    }
    MPI_Allreduce(sendBuf, recvBuf, count, MPI_DOUBLE_INT, MPI_MINLOC, MPI_COMM_WORLD);
#else
    for (int ii=0; ii<count; ++ii)
    {
       recvBuf[ii].val = sendBuf[ii].val;
       recvBuf[ii].rank = sendBuf[ii].rank;
    }
#endif
}

void maxRankDoubleParallel(RankReduceData* sendBuf, RankReduceData* recvBuf, int count) {
#ifdef DO_MPI
    if(currentThread == ConsumerThread){
        printf("\n\n\nHERE IS A PROBLEM MAX RANK DOUBLE PARALLEL \n\n\n");
        exit(34);
    }
    MPI_Allreduce(sendBuf, recvBuf, count, MPI_DOUBLE_INT, MPI_MAXLOC, MPI_COMM_WORLD);
#else
    for (int ii=0; ii<count; ++ii)
    {
       recvBuf[ii].val = sendBuf[ii].val;
       recvBuf[ii].rank = sendBuf[ii].rank;
    }
#endif
}

/// \param [in] count Length of buf in bytes.
void bcastParallel(void* buf, int count, int root) {
#ifdef DO_MPI
    if(currentThread == ConsumerThread){
        printf("\n\n\nHERE IS A PROBLEM IN BCAST PARALLEL \n\n\n");
        exit(34);
    }

    MPI_Bcast(buf, count, MPI_BYTE, root, MPI_COMM_WORLD);

#endif
}

int builtWithMpi(void) {
#ifdef DO_MPI
    return 1;
#else
    return 0;
#endif
}


