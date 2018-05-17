/// \file
/// Leapfrog time integrator

#include "timestep.h"

#include "CoMDTypes.h"
#include "linkCells.h"
#include "parallel.h"
#include "performanceTimers.h"

static void advanceVelocity(SimFlat* s, int nBoxes, real_t dt);
static void advanceVelocity_Producer(SimFlat* s, int nBoxes, real_t dt);
static void advanceVelocity_Consumer(SimFlat* s, int nBoxes, real_t dt);

static void advancePosition(SimFlat* s, int nBoxes, real_t dt);
static void advancePosition_Producer(SimFlat* s, int nBoxes, real_t dt);
static void advancePosition_Consumer(SimFlat* s, int nBoxes, real_t dt);


/// Advance the simulation time to t+dt using a leap frog method
/// (equivalent to velocity verlet).
///
/// Forces must be computed before calling the integrator the first time.
///
///  - Advance velocities half time step using forces
///  - Advance positions full time step using velocities
///  - Update link cells and exchange remote particles
///  - Compute forces
///  - Update velocities half time step using forces
///
/// This leaves positions, velocities, and forces at t+dt, with the
/// forces ready to perform the half step velocity update at the top of
/// the next call.
///
/// After nSteps the kinetic energy is computed for diagnostic output.
double timestep(SimFlat* s, int nSteps, real_t dt) {
   for (int ii = 0; ii < nSteps; ++ii) {
      startTimer(velocityTimer);
      advanceVelocity(s, s->boxes->nLocalBoxes, 0.5 * dt);
      stopTimer(velocityTimer);

      startTimer(positionTimer);
      advancePosition(s, s->boxes->nLocalBoxes, dt);
      stopTimer(positionTimer);

      startTimer(redistributeTimer);
      redistributeAtoms(s);
      stopTimer(redistributeTimer);

      startTimer(computeForceTimer);
      computeForce(s);
      stopTimer(computeForceTimer);

      startTimer(velocityTimer);
      advanceVelocity(s, s->boxes->nLocalBoxes, 0.5 * dt);
      stopTimer(velocityTimer);
   }

   kineticEnergy(s);

   return s->ePotential;
}

double timestep_Producer(SimFlat* s, int nSteps, real_t dt) {
    for (int ii = 0; ii < nSteps; ++ii) {
        startTimer(velocityTimer);
        advanceVelocity_Producer(s, s->boxes->nLocalBoxes, 0.5 * dt);
        stopTimer(velocityTimer);

        startTimer(positionTimer);
        advancePosition_Producer(s, s->boxes->nLocalBoxes, dt);
        stopTimer(positionTimer);

        startTimer(redistributeTimer);
        redistributeAtoms_Producer(s);
        stopTimer(redistributeTimer);

        startTimer(computeForceTimer);
        computeForce(s);
        stopTimer(computeForceTimer);

        startTimer(velocityTimer);
        advanceVelocity_Producer(s, s->boxes->nLocalBoxes, 0.5 * dt);
        stopTimer(velocityTimer);
    }

//    kineticEnergy_Producer(s);
    kineticEnergy(s);

    return s->ePotential;
}

double timestep_Consumer(SimFlat* s, int nSteps, real_t dt) {
    for (int ii = 0; ii < nSteps; ++ii) {
        //startTimer(velocityTimer);
        advanceVelocity_Consumer(s, s->boxes->nLocalBoxes, 0.5 * dt);
        //stopTimer(velocityTimer);

        //startTimer(positionTimer);
        advancePosition_Consumer(s, s->boxes->nLocalBoxes, dt);
        //stopTimer(positionTimer);

        //startTimer(redistributeTimer);
        redistributeAtoms_Consumer(s);
        //stopTimer(redistributeTimer);

        //startTimer(computeForceTimer);
        computeForce(s);
        //stopTimer(computeForceTimer);

        //startTimer(velocityTimer);
        advanceVelocity_Consumer(s, s->boxes->nLocalBoxes, 0.5 * dt);
        //stopTimer(velocityTimer);
    }

//    kineticEnergy_Consumer(s);
    kineticEnergy(s);

    return s->ePotential;
}

void computeForce(SimFlat* s) {
   s->pot->force(s);
}


void advanceVelocity(SimFlat* s, int nBoxes, real_t dt) {
   for (int iBox = 0; iBox < nBoxes; iBox++) {
      for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
         s->atoms->p[iOff][0] += dt * s->atoms->f[iOff][0];
         s->atoms->p[iOff][1] += dt * s->atoms->f[iOff][1];
         s->atoms->p[iOff][2] += dt * s->atoms->f[iOff][2];
      }
   }
}

void advanceVelocity_Producer(SimFlat* s, int nBoxes, real_t dt) {
    // TODO improve macro to support this loop patter with multiple values to produce
    // We can have the values as the last values of the macro to have a arg list separated by comma
    // and we can send the number of values to replicate in order to use the info for the var grouping
    for (int iBox = 0; iBox < nBoxes; iBox++) {
        for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
            s->atoms->p[iOff][0] += dt * s->atoms->f[iOff][0];
            s->atoms->p[iOff][1] += dt * s->atoms->f[iOff][1];
            s->atoms->p[iOff][2] += dt * s->atoms->f[iOff][2];
            //RHT_Produce_Secure(s->atoms->p[iOff][0]);
            //RHT_Produce_Secure(s->atoms->p[iOff][1]);
            //RHT_Produce_Secure(s->atoms->p[iOff][2]);
        }
    }
}

void advanceVelocity_Consumer(SimFlat* s, int nBoxes, real_t dt) {
    for (int iBox = 0; iBox < nBoxes; iBox++) {
        for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
            s->atoms->p[iOff][0] += dt * s->atoms->f[iOff][0];
            s->atoms->p[iOff][1] += dt * s->atoms->f[iOff][1];
            s->atoms->p[iOff][2] += dt * s->atoms->f[iOff][2];
            //RHT_Consume_Check(s->atoms->p[iOff][0]);
            //RHT_Consume_Check(s->atoms->p[iOff][1]);
            //RHT_Consume_Check(s->atoms->p[iOff][2]);
        }
    }
}

void advancePosition(SimFlat* s, int nBoxes, real_t dt) {
   for (int iBox = 0; iBox < nBoxes; iBox++) {
      for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
         int iSpecies = s->atoms->iSpecies[iOff];
         real_t invMass = 1.0 / s->species[iSpecies].mass;
         s->atoms->r[iOff][0] += dt * s->atoms->p[iOff][0] * invMass;
         s->atoms->r[iOff][1] += dt * s->atoms->p[iOff][1] * invMass;
         s->atoms->r[iOff][2] += dt * s->atoms->p[iOff][2] * invMass;
      }
   }
}

void advancePosition_Producer(SimFlat* s, int nBoxes, real_t dt) {
    // TODO improve macro to support this loop patter with multiple values to produce, same as before
    for (int iBox = 0; iBox < nBoxes; iBox++) {
        for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
            int iSpecies = s->atoms->iSpecies[iOff];
            real_t invMass = 1.0 / s->species[iSpecies].mass;
            s->atoms->r[iOff][0] += dt * s->atoms->p[iOff][0] * invMass;
            s->atoms->r[iOff][1] += dt * s->atoms->p[iOff][1] * invMass;
            s->atoms->r[iOff][2] += dt * s->atoms->p[iOff][2] * invMass;
            //RHT_Produce_Secure(s->atoms->r[iOff][0]);
            //RHT_Produce_Secure(s->atoms->r[iOff][1]);
            //RHT_Produce_Secure(s->atoms->r[iOff][2]);
        }
    }
}

void advancePosition_Consumer(SimFlat* s, int nBoxes, real_t dt) {
    for (int iBox = 0; iBox < nBoxes; iBox++) {
        for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
            int iSpecies = s->atoms->iSpecies[iOff];
            real_t invMass = 1.0 / s->species[iSpecies].mass;
            s->atoms->r[iOff][0] += dt * s->atoms->p[iOff][0] * invMass;
            s->atoms->r[iOff][1] += dt * s->atoms->p[iOff][1] * invMass;
            s->atoms->r[iOff][2] += dt * s->atoms->p[iOff][2] * invMass;
            //RHT_Consume_Check(s->atoms->r[iOff][0]);
            //RHT_Consume_Check(s->atoms->r[iOff][1]);
            //RHT_Consume_Check(s->atoms->r[iOff][2]);
        }
    }
}

/// Calculates total kinetic and potential energy across all tasks.  The
/// local potential energy is a by-product of the force routine.
void kineticEnergy(SimFlat* s) {
   real_t eLocal[2];
   eLocal[0] = s->ePotential;
   eLocal[1] = 0;
   for (int iBox = 0; iBox < s->boxes->nLocalBoxes; iBox++) {
      for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
         int iSpecies = s->atoms->iSpecies[iOff];
         real_t invMass = 0.5 / s->species[iSpecies].mass;
         eLocal[1] += (s->atoms->p[iOff][0] * s->atoms->p[iOff][0] +
                       s->atoms->p[iOff][1] * s->atoms->p[iOff][1] +
                       s->atoms->p[iOff][2] * s->atoms->p[iOff][2]) * invMass;
      }
   }

   real_t eSum[2];
   startTimer(commReduceTimer);
   addRealParallel(eLocal, eSum, 2);
   stopTimer(commReduceTimer);

   s->ePotential = eSum[0];
   s->eKinetic = eSum[1];
}

void kineticEnergy_Producer(SimFlat* s) {
    real_t eLocal[2];
    eLocal[0] = s->ePotential;
    eLocal[1] = 0;
    for (int iBox = 0; iBox < s->boxes->nLocalBoxes; iBox++) {
        for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
            int iSpecies = s->atoms->iSpecies[iOff];
            real_t invMass = 0.5 / s->species[iSpecies].mass;
            eLocal[1] += (s->atoms->p[iOff][0] * s->atoms->p[iOff][0] +
                          s->atoms->p[iOff][1] * s->atoms->p[iOff][1] +
                          s->atoms->p[iOff][2] * s->atoms->p[iOff][2]) * invMass;
        }
    }

    real_t eSum[2];
    startTimer(commReduceTimer);
    addRealParallel_Producer(eLocal, eSum, 2);
    stopTimer(commReduceTimer);

    s->ePotential = eSum[0];
    s->eKinetic = eSum[1];
}

void kineticEnergy_Consumer(SimFlat* s) {
    real_t eLocal[2];
    eLocal[0] = s->ePotential;
    eLocal[1] = 0;
    for (int iBox = 0; iBox < s->boxes->nLocalBoxes; iBox++) {
        for (int iOff = MAXATOMS * iBox, ii = 0; ii < s->boxes->nAtoms[iBox]; ii++, iOff++) {
            int iSpecies = s->atoms->iSpecies[iOff];
            real_t invMass = 0.5 / s->species[iSpecies].mass;
            eLocal[1] += (s->atoms->p[iOff][0] * s->atoms->p[iOff][0] +
                          s->atoms->p[iOff][1] * s->atoms->p[iOff][1] +
                          s->atoms->p[iOff][2] * s->atoms->p[iOff][2]) * invMass;
        }
    }

    real_t eSum[2];
//    startTimer(commReduceTimer);
    addRealParallel_Consumer(eLocal, eSum, 2);
//    stopTimer(commReduceTimer);

    s->ePotential = eSum[0];
    s->eKinetic = eSum[1];
}

/// \details
/// This function provides one-stop shopping for the sequence of events
/// that must occur for a proper exchange of halo atoms after the atom
/// positions have been updated by the integrator.
///
/// - updateLinkCells: Since atoms have moved, some may be in the wrong
///   link cells.
/// - haloExchange (atom version): Sends atom data to remote tasks. 
/// - sort: Sort the atoms.
///
/// \see updateLinkCells
/// \see initAtomHaloExchange
/// \see sortAtomsInCell
void redistributeAtoms(SimFlat* sim) {
   updateLinkCells(sim->boxes, sim->atoms);

   startTimer(atomHaloTimer);
   haloExchange(sim->atomExchange, sim);
   stopTimer(atomHaloTimer);

   for (int ii = 0; ii < sim->boxes->nTotalBoxes; ++ii)
      sortAtomsInCell(sim->atoms, sim->boxes, ii);
}

void redistributeAtoms_Producer(SimFlat* sim) {
    updateLinkCells_Producer(sim->boxes, sim->atoms);

    startTimer(atomHaloTimer);
    haloExchange(sim->atomExchange, sim);
    stopTimer(atomHaloTimer);

    for (int ii = 0; ii < sim->boxes->nTotalBoxes; ++ii)
        sortAtomsInCell(sim->atoms, sim->boxes, ii);
}


void redistributeAtoms_Consumer(SimFlat* sim) {
    updateLinkCells_Consumer(sim->boxes, sim->atoms);

    startTimer(atomHaloTimer);
    haloExchange(sim->atomExchange, sim);
    stopTimer(atomHaloTimer);

    for (int ii = 0; ii < sim->boxes->nTotalBoxes; ++ii)
        sortAtomsInCell(sim->atoms, sim->boxes, ii);
}
