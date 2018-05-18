cmake_minimum_required(VERSION 3.5)
project(CoMDRHT)

set(CMAKE_BUILD_TYPE Release) # optimizations, but debuging is not allowed
#set(CMAKE_BUILD_TYPE Debug) # NO optimizations, debuging allowed

#set(CMAKE_VERBOSE_MAKEFILE ON)


find_package(MPI REQUIRED)

include_directories(${MPI_INCLUDE_PATH})

set(CMAKE_CXX_STANDARD 11)

#-ftree-vectorize

# mpi or not
#set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDO_MPI -DMPICH_IGNORE_CXX_SEEK")

# print output to console and files
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_GNU_SOURCE -DPRINT_CMD=0")

# fast math or not, there is a problem when nan values are found when this options is enabled
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffast-math")

# General compilation flags
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -funroll-all-loops") #just for gcc
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBRANCH_HINT=1") # should always be true
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DCOUNT_QUEUE_DESYNC=0")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DAPPROACH_NEW_ENQ_INDEX=0") # use with APPROACH_NEW_LIMIT
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DPERCENTAGE_OF_REPLICATION=0")

# Modify this flags to test different approaches
set(FLAGS_CURRENT "${CMAKE_CXX_FLAGS}")

# These are other approaches of the literature
set(FLAGS_CURRENT "${FLAGS_CURRENT} -DAPPROACH_USING_POINTERS=0")
set(FLAGS_CURRENT "${FLAGS_CURRENT} -DAPPROACH_ALREADY_CONSUMED=0")
set(FLAGS_CURRENT "${FLAGS_CURRENT} -DAPPROACH_SRMT=1")

# These are our approaches
set(FLAGS_CURRENT "${FLAGS_CURRENT} -DAPPROACH_CONSUMER_NO_SYNC=0")
set(FLAGS_CURRENT "${FLAGS_CURRENT} -DAPPROACH_NEW_LIMIT=0") # new limit includes the consumer no sync
set(FLAGS_CURRENT "${FLAGS_CURRENT} -DAPPROACH_WRITE_INVERTED_NEW_LIMIT=0")
set(FLAGS_CURRENT "${FLAGS_CURRENT} -DVAR_GROUPING=0") # it can be used with any of the below approaches

set(SOURCE_FILES
        CoMD.c cmdLineParser.h cmdLineParser.c CoMD_info.h CoMDTypes.h
        RHT.h RHT.c
        constants.h decomposition.h decomposition.c eam.h eam.c haloExchange.h haloExchange.c
        initAtoms.h initAtoms.c linkCells.h linkCells.c ljForce.h ljForce.c
        memUtils.h mycommand.h mycommand.c mytype.h parallel.h parallel.c
        performanceTimers.h performanceTimers.c random.h random.c timestep.h timestep.c
        yamlOutput.h yamlOutput.c
        )

function(createExecutable exeName compFlags)
    add_executable(${exeName} ${SOURCE_FILES})
    set_target_properties(${exeName} PROPERTIES COMPILE_FLAGS "${compFlags}")
    target_link_libraries(${exeName} ${MPI_LIBRARIES})
    target_link_libraries(${exeName} pthread)
    target_link_libraries(${exeName} m) #math
    if(MPI_COMPILE_FLAGS)
        set_target_properties(${exeName} PROPERTIES COMPILE_FLAGS "${MPI_COMPILE_FLAGS}")
    endif()

    if(MPI_LINK_FLAGS)
        set_target_properties(${exeName} PROPERTIES LINK_FLAGS "${MPI_LINK_FLAGS}")
    endif()
endfunction(createExecutable)



#current, for testing
createExecutable("CoMD-RHT" ${FLAGS_CURRENT})

# using pointer flags
set(FLAGS_USING_POINTERS "${CMAKE_CXX_FLAGS} -DAPPROACH_USING_POINTERS=1")
set(FLAGS_USING_POINTERS_VG " ${FLAGS_USING_POINTERS} -DVAR_GROUPING=1")

# using already consumed value flags
set(FLAGS_ALREADY_CONSUMED "${CMAKE_CXX_FLAGS} -DAPPROACH_ALREADY_CONSUMED=1")
set(FLAGS_ALREADY_CONSUMED_VG " ${FLAGS_ALREADY_CONSUMED} -DVAR_GROUPING=1")

# using new limit approach
set(FLAGS_NEW_LIMIT "${CMAKE_CXX_FLAGS} -DAPPROACH_NEW_LIMIT=1")
set(FLAGS_NEW_LIMIT_VG " ${FLAGS_NEW_LIMIT} -DVAR_GROUPING=1")

# using new limit write inverted approach
set(FLAGS_NEW_LIMIT_INVERTED "${CMAKE_CXX_FLAGS} -DAPPROACH_WRITE_INVERTED_NEW_LIMIT=1")
set(FLAGS_NEW_LIMIT_INVERTED_VG " ${FLAGS_NEW_LIMIT_INVERTED} -DVAR_GROUPING=1")

# un comment the next lines to create multiple executables, with different configurations
#using pointers
#createExecutable("CoMD-RHT-UP" ${FLAGS_USING_POINTERS})
#createExecutable("CoMD-RHT-UP-VG" ${FLAGS_USING_POINTERS_VG})

# already consumed
#createExecutable("CoMD-RHT-AC" ${FLAGS_ALREADY_CONSUMED})
#createExecutable("CoMD-RHT-AC-VG" ${FLAGS_ALREADY_CONSUMED_VG})

# new limit
#createExecutable("CoMD-RHT-NL" ${FLAGS_NEW_LIMIT})
#createExecutable("CoMD-RHT-NL-VG" ${FLAGS_NEW_LIMIT_VG})

# new limit inverted
#createExecutable("CoMD-RHT-NLI" ${FLAGS_NEW_LIMIT_INVERTED})
#createExecutable("CoMD-RHT-NLI-VG" ${FLAGS_NEW_LIMIT_INVERTED_VG})

