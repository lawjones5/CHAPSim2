module les_mod
    use, intrinsic :: iso_fortran_env, only: wp => real64
    implicit none
    private :: initialize_les, calculate_cell_grad, calculate_stress_tensor, calculate_stress_tensor_square
    private :: calculate_WALE_tensor, calculate_WALE_invariants

    real(WP), dimension( dm%dccc%xsz(1), dm%dccc%xsz(2), dm%dccc%xsz(3), 3, 3 ) :: S, Ssqr, SD
    
    public :: calculate_les_wale
    public :: calculate_les_smag

    logical :: les_initialized = .false.

contains
    subroutine init_les()
        ! Initialize LES parameters and variables
        
        les_initialized = .true.
    end subroutine init_les

    subroutine calculate_cell_grad()
        ! Calculate or import the gradient of the velocity field for LES
        !find gij
        !----------------------------------------------------------------------------------------------------------
        !   preparation for du_i/dx_j
        !----------------------------------------------------------------------------------------------------------
        
        ! du/dx, du/dy, du/dz
        call Get_x_1der_P2C_3D(fl%qx, accc_xpencil, dm, dm%iAccuracy, dm%ibcx_qx, dm%fbcx_qx)
        dudx(:, :, :, 1, 1) = accc_xpencil(:, :, :)
        call transpose_x_to_y(fl%qx, apcc_ypencil, dm%dpcc)
        call Get_y_1der_C2P_3D(apcc_ypencil, appc_ypencil, dm, dm%iAccuracy, dm%ibcy_qx, dm%fbcy_qx)
        fbcy_p4c = MAXP
        if(dm%icase == ICASE_PIPE) then
        call axis_mirror_fbcy(appc_ypencil, IPENCIL(2), fbcy_p4c, dm%knc_sym, dm%dppc, is_odd = .true., &
                                axis_mode = AXIS_RECON_M1, assign_axis_to_var = .true., nr = 0, opt_dz = dm%h(3))
        end if
        call Get_y_midp_P2C_3D(appc_ypencil, apcc_ypencil, dm, dm%iAccuracy, dm%ibcy_qx) ! should be BC of du/dy
        call transpose_y_to_x(apcc_ypencil, apcc_xpencil, dm%dpcc)
        call Get_x_midp_P2C_3D(apcc_xpencil, accc_xpencil, dm, dm%iAccuracy, dm%ibcx_qx) ! should be BC of du/dy
        dudx(:, :, :, 1, 2) = accc_xpencil(:, :, :)
        call transpose_to_z_pencil(fl%qx, apcc_zpencil, dm%dpcc, IPENCIL(1))
        call Get_z_1der_C2P_3D(apcc_zpencil, apcp_zpencil, dm, dm%iAccuracy, dm%ibcz_qx, dm%fbcz_qx)
        call Get_z_midp_P2C_3D(apcp_zpencil, apcc_zpencil, dm, dm%iAccuracy, dm%ibcz_qx) ! should be BC of du/dz
        call transpose_from_z_pencil(apcc_zpencil, apcc_xpencil, dm%dccc, IPENCIL(1))
        call Get_x_midp_P2C_3D(apcc_xpencil, accc_xpencil, dm, dm%iAccuracy, dm%ibcx_qx) ! should be BC of du/dz
        dudx(:, :, :, 1, 3) = accc_xpencil(:, :, :)
        ! dv/dx, dv/dy, dv/dz
        call Get_x_1der_C2P_3D(fl%qy, appc_xpencil, dm, dm%iAccuracy, dm%ibcx_qy, dm%fbcx_qy)
        call Get_x_midp_P2C_3D(appc_xpencil, acpc_xpencil, dm, dm%iAccuracy, dm%ibcx_qy) ! should be BC of dv/dx
        call transpose_x_to_y(acpc_xpencil, acpc_ypencil, dm%dcpc)
        call Get_y_midp_P2C_3D(acpc_ypencil, accc_ypencil, dm, dm%iAccuracy, dm%ibcy_qy) ! should be BC of dv/dy
        call transpose_y_to_x(accc_ypencil, accc_xpencil, dm%dccc)
        dudx(:, :, :, 2, 1) = accc_xpencil(:, :, :)
        call transpose_x_to_y(fl%qy, acpc_ypencil, dm%dcpc)
        call Get_y_1der_P2C_3D(acpc_ypencil, accc_ypencil, dm, dm%iAccuracy, dm%ibcy_qy, dm%fbcy_qy)
        call transpose_y_to_x(accc_ypencil, accc_xpencil, dm%dccc)
        dudx(:, :, :, 2, 2) = accc_xpencil(:, :, :)
        call transpose_to_z_pencil(fl%qy, acpc_zpencil, dm%dcpc, IPENCIL(1))
        call Get_z_1der_C2P_3D(acpc_zpencil, acpp_zpencil, dm, dm%iAccuracy, dm%ibcz_qy, dm%fbcz_qy)
        call Get_z_midp_P2C_3D(acpp_zpencil, acpc_zpencil, dm, dm%iAccuracy, dm%ibcz_qy) ! should be BC of dv/dz
        call transpose_z_to_y(acpc_zpencil, acpc_ypencil, dm%dcpc)
        call Get_y_midp_P2C_3D(acpc_ypencil, accc_ypencil, dm, dm%iAccuracy, dm%ibcy_qy) ! should be BC of dv/dz
        call transpose_y_to_x(accc_ypencil, accc_xpencil, dm%dccc)
        dudx(:, :, :, 2, 3) = accc_xpencil(:, :, :)
        ! dw/dx, dw/dy, dw/dz
        call Get_x_1der_C2P_3D(fl%qz, apcp_xpencil, dm, dm%iAccuracy, dm%ibcx_qz, dm%fbcx_qz)
        call Get_x_midp_P2C_3D(apcp_xpencil, accp_xpencil, dm, dm%iAccuracy, dm%ibcx_qz) ! should be BC of dv/dx
        call transpose_to_z_pencil(accp_xpencil, accp_zpencil, dm%dccp, IPENCIL(1))
        call Get_z_midp_P2C_3D(accp_zpencil, accc_zpencil, dm, dm%iAccuracy, dm%ibcz_qz) ! should be BC of dv/dy
        call transpose_from_z_pencil(accc_zpencil, accc_xpencil, dm%dccc, IPENCIL(1))
        dudx(:, :, :, 3, 1) = accc_xpencil(:, :, :)
        call transpose_x_to_y(fl%qz, accp_ypencil, dm%dccp)
        call Get_y_1der_C2P_3D(accp_ypencil, acpp_ypencil, dm, dm%iAccuracy, dm%ibcy_qz, dm%fbcy_qz)
        fbcy_c4p = MAXP
        if(dm%icase == ICASE_PIPE) then
        call axis_mirror_fbcy(acpp_ypencil, IPENCIL(2), fbcy_c4p, dm%knc_sym, dm%dcpp, is_odd = .false., &
                                axis_mode = AXIS_RECON_M0_M2, assign_axis_to_var = .true., nr = 0, opt_dz = dm%h(3))
        end if
        call Get_y_midp_P2C_3D(acpp_ypencil, accp_ypencil, dm, dm%iAccuracy, dm%ibcy_qz) ! should be BC of du/dy
        call transpose_to_z_pencil(accp_ypencil, accp_zpencil, dm%dccp, IPENCIL(2))
        call Get_z_midp_P2C_3D(accp_zpencil, accc_zpencil, dm, dm%iAccuracy, dm%ibcz_qz) ! should be BC of dv/dy
        call transpose_from_z_pencil(accc_zpencil, accc_xpencil, dm%dccc, IPENCIL(1))
        dudx(:, :, :, 3, 2) = accc_xpencil(:, :, :)
        call transpose_to_z_pencil(fl%qz, accp_zpencil, dm%dccp, IPENCIL(1))
        call Get_z_1der_P2C_3D(accp_zpencil, accc_zpencil, dm, dm%iAccuracy, dm%ibcz_qz, dm%fbcz_qz)
        call transpose_from_z_pencil(accc_zpencil, accc_xpencil, dm%dccc, IPENCIL(1))
        dudx(:, :, :, 3, 3) = accc_xpencil(:, :, :)
        

    end subroutine calculate_cell_grad

    
    subroutine calculate_stress_tensor()
        ! Calculate the stress tensor based on the velocity gradients 
        ! find Sij = 0.5 * (gij + gji)

        real(wp) :: S(3, 3)

        ! S = (gij + transpose(gij)) / 2.0
        do i = 1, 3
            do j = 1, 3
                S(:, :, :, i, j) = 0.5 * (dudx(:, :, :, i, j) + dudx(:, :, :, j, i))
            end do
        end do
    end subroutine calculate_stress_tensor

    
    subroutine calculate_stress_tensor_square()
        ! Calculate the stress tensor squared based on the stress tensor
        ! find Sij * Sji
        
        do i = 1, 3
            do j = 1, 3
                Ssqr(:, :, :) = S(:, :, :, 1, 1)**2 + S(:, :, :, 1, 2)**2 + S(:, :, :, 1, 3)**2 &
                                + S(:, :, :, 2, 1)**2 + S(:, :, :, 2, 2)**2 + S(:, :, :, 2, 3)**2 &
                                + S(:, :, :, 3, 1)**2 + S(:, :, :, 3, 2)**2 + S(:, :, :, 3, 3)**2
            end do
        end do
    end subroutine calculate_stress_tensor_square


    subroutine calculate_wale_tensor()
        ! Calculate the WALE tensor based on the velocity gradients and the trace of the square of the velocity gradient tensor
        ! find Sij^d = 0.5 * (gij^2 + gji^2) - (1/3) * delta_ij * gkk^2)
        trace_dudx2 = dudx(:, :, :, 1, 1)**2 + dudx(:, :, :, 2, 2)**2 + dudx(:, :, :, 3, 3)**2

        do i = 1, 3
            do j = 1, 3
                
                SD(:, :, :, i, j) = 0.5 * (dudx(:, :, :, i, 1) * dudx(:, :, :, 1, j) + dudx(:, :, :, i, 2) * dudx(:, :, :, 2, j) + dudx(:, :, :, i, 3) * dudx(:, :, :, 3, j) &
                                            + dudx(:, :, :, j, 1) * dudx(:, :, :, 1, i) + dudx(:, :, :, j, 2) * dudx(:, :, :, 2, i) + dudx(:, :, :, j, 3) * dudx(:, :, :, 3, i))

                ! Subtract the isotropic part to ensure the tensor is traceless when i = j
                if (i == j) then
                    SD(:, :, :, i, j) = SD(:, :, :, i, j) - (1.0/3.0) * trace_dudx2
                end if

            end do
        end do
        

    end subroutine calculate_wale_tensor

 
    subroutine calculate_wale_invariants()
        ! Calculate the WALE invariants based on the square of the WALE tensor
        ! find Sij^d * Sji^d

        do i = 1, 3
            do j = 1, 3
                WALE_invariants(:, :, :) = SD(:, :, :, 1, 1)**2 + SD(:, :, :, 1, 2)**2 + SD(:, :, :, 1, 3)**2 &
                                            + SD(:, :, :, 2, 1)**2 + SD(:, :, :, 2, 2)**2 + SD(:, :, :, 2, 3)**2 &
                                            + SD(:, :, :, 3, 1)**2 + SD(:, :, :, 3, 2)**2 + SD(:, :, :, 3, 3)**2
            end do
        end do
        
    end subroutine calculate_wale_invariants

    subroutine calculate_eddy_viscosity_wale()
        ! Calculate the eddy viscosity based on the WALE invariants and the grid scale
        ! delta = (dx * dy * dz)^(1/3) or min(dx, dy, dz) or (dx^2 * dy^2 * dz^2)^(1/3)/sqrt(3)
        
        ! find nu_t = (Cw * delta)^2 * (Sij^d * Sji^d)^(3/2) / ((Sij * Sji)^(3/2) + (Sij^d * Sji^d)^(5/4))
        
        !needs fuction for chaning cw in input file
        Cw = 0.5
        delta = (dm%h(1) * dm%h(2) * dm%h(3))**(1.0/3.0)

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

        nu_t
        fl%tVisc = nu_t * fl$dDens

    end subroutine calculate_les_wale

    subroutine calculate_les_smag()
        
        ! call calculate_cell_grad()
        ! call calculate_stress_tensor()
        ! call calculate_stress_tensor_square()
        
        ! mag_S = sqrt(2 * Ssqr)
        ! nu_t_smag = (Cs * delta)**2 * mag_S
        ! visc = visc + nu_t_smag

    end subroutine calculate_les_smag
end module les_mod