/// \file
/// Leapfrog time integrator

#ifndef __LEAPFROG_H
#define __LEAPFROG_H

#include "CoMDTypes.h"

double timestep(SimFlat* s, int n, real_t dt);
double timestep_Producer(SimFlat* s, int n, real_t dt);
double timestep_Consumer(SimFlat* s, int n, real_t dt);

void computeForce(SimFlat* s);
void computeForce_Producer(SimFlat* s);
void computeForce_Consumer(SimFlat* s);

void kineticEnergy(SimFlat* s);
void kineticEnergy_Producer(SimFlat* s);
void kineticEnergy_Consumer(SimFlat* s);

/// Update local and remote link cells after atoms have moved.
void redistributeAtoms(struct SimFlatSt* sim);
void redistributeAtoms_Producer(struct SimFlatSt* sim);
void redistributeAtoms_Consumer(struct SimFlatSt* sim);

#endif
