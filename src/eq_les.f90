module les_mod
    use, intrinsic :: iso_fortran_env, only: wp => real64
    implicit none
    private :: initialize_les, calculate_cell_grad, calculate_stress_tensor, calculate_stress_tensor_square
    private :: calculate_WALE_tensor, calculate_WALE_invariants

  
    public :: calculate_les

    logical :: les_initialized = .false.

contains
    subroutine init_les()
        ! Initialize LES parameters and variables
        
        les_initialized = .true.
    end subroutine init_les

    subroutine calculate_cell_grad()
        ! Calculate or import the gradient of the velocity field for LES
        !find gij
        real(wp) :: gij(3, 3)

        qxdx_ccc_xpencil
        qydx_ppc_xpencil
        qzdx_pcp_xpencil

        qxdy_ppc_xpencil
        qydy_pcc_xpencil
        qzdy_cpp_zpencil

        qxdz_pcp_xpencil
        qydz_cpp_zpencil   
        qzdz_pcc_xpencil

        interpolate_velocity_gradients() ! This is a placeholder for the actual interpolation method to compute the velocity gradients at the cell centers

        gij(1, 1) = qxdx_ccc_xpencil
        gij(1, 2) = qxdy_ppc_xpencil
        gij(1, 3) = qxdz_pcp_xpencil

        gij(2, 1) = qydx_ppc_xpencil
        gij(2, 2) = qydy_pcc_xpencil
        gij(2, 3) = qydz_cpp_zpencil

        gij(3, 1) = qzdx_pcp_xpencil
        gij(3, 2) = qzdy_cpp_zpencil
        gij(3, 3) = qzdz_pcc_xpencil

    end subroutine calculate_cell_grad

    
    subroutine calculate_stress_tensor()
        ! Calculate the stress tensor based on the velocity gradients 
        ! find Sij = 0.5 * (gij + gji)

        real(wp) :: S(3, 3)

        ! S = (gij + transpose(gij)) / 2.0

        Sxx = qxdx_ccc_xpencil
        Sxy = 0.5 * (qxdy_ccc_xpencil + qydx_ppc_xpencil)
        Sxz = 0.5 * (qxdz_pcp_xpencil + qzdx_pcp_xpencil)

        Syx = Sxy
        Syy = qydy_pcc_xpencil
        Syz = 0.5 * (qydz_cpp_zpencil + qzdy_cpp_zpencil)

        Szz = qzdz_pcc_xpencil
        Szy = Syz
        Szx = Sxz

        S(1, 1) = Sxx
        S(1, 2) = Sxy
        S(1, 3) = Sxz
        S(2, 1) = Syx
        S(2, 2) = Syy
        S(2, 3) = Syz
        S(3, 1) = Szx
        S(3, 2) = Szy
        S(3, 3) = Szz
        

    end subroutine calculate_stress_tensor

    
    subroutine calculate_stress_tensor_square()
        ! Calculate the stress tensor squared based on the stress tensor
        ! find Sij * Sji
        Ssqr = S**2
        
    end subroutine calculate_stress_tensor_square


    subroutine calculate_WALE_tensor()
        ! Calculate the WALE tensor based on the velocity gradients and the trace of the square of the velocity gradient tensor
        ! find Sij^d = 0.5 * (gij^2 + gji^2) - (1/3) * delta_ij * gkk^2)
        
        SD = 0.5 * (gij**2 + transpose(gij)**2) - (1.0/3.0) * identity_matrix * trace(gij**2)

    end subroutine calculate_WALE_tensor

 
    subroutine calculate_WALE_invariants()
        ! Calculate the WALE invariants based on the square of the WALE tensor
        ! find Sij^d * Sji^d

        WALE_invariants = SD**2
        
    end subroutine calculate_WALE_invariants

    subroutine calculate_eddy_viscosity()
        ! Calculate the eddy viscosity based on the WALE invariants and the grid scale
        ! delta = (dx * dy * dz)^(1/3) or min(dx, dy, dz) or (dx^2 * dy^2 * dz^2)^(1/3)/sqrt(3)
        
        ! find nu_t = (Cw * delta)^2 * (Sij^d * Sji^d)^(3/2) / ((Sij * Sji)^(3/2) + (Sij^d * Sji^d)^(5/4))
        
        nu_t = (Cw * delta)**2 * (WALE_invariants)**(3.0/2.0) / ((Ssqr)**(3.0/2.0) + (WALE_invariants)**(5.0/4.0))

    end subroutine calculate_eddy_viscosity

    subroutine calculate_les_wale(visc)
        ! Calculate the LES viscous terms and update the momentum equations
        call calculate_cell_grad()
        call calculate_stress_tensor()
        call calculate_stress_tensor_square()
        call calculate_WALE_tensor()
        call calculate_WALE_invariants()
        call calculate_eddy_viscosity()

        visc = visc + nu_t

    end subroutine calculate_les_wale

    subroutine calculate_les_smag(arg1,  arg2)
        
        call calculate_cell_grad()
        call calculate_stress_tensor()
        call calculate_stress_tensor_square()
        
        mag_S = sqrt(2 * Ssqr)
        nu_t_smag = (Cs * delta)**2 * mag_S
        visc = visc + nu_t_smag

    end subroutine calculate_les_smag
end module les_mod