section	.text
   
   global _start         
	
_start:                  
   
   mov r8, nb_perm
   call permutations

   mov r8, rbx
   mov r9, rcx
   mov r10, 0
   mov eax, 4
   mov ebx, 1
   mov ecx, m1
   mov edx, 1
   int 80h
   call affichage
   mov eax, 4
   mov ebx, 1
   mov ecx, m3
   mov edx, 2
   int 80h

exit:

   mov	  eax,1          ;system call number (sys_exit)
   int	  0x80           ;call kernel

;le r10 nb d affichage avant ][
affichage:
   cmp r8,r9
   jge rec_fin

   cmp r10, nb_perm
   jl affichage_s

   mov eax, 4
   mov ebx, 1
   mov ecx, m2
   mov edx, 3
   int 80h

   mov r10, 0

affichage_s:

   mov rax, [r8]
   mov [affiche_place], rax
   add byte [affiche_place], 48

   mov eax, 4
   mov ebx, 1
   mov rcx, affiche_place
   mov edx, 1
   int 80h 

   inc r10
   add r8, 8
   jmp affichage


ask_brk:

   mov eax, 12
   syscall
   ret

;r8 : nombre de permutation
;r9: permutations en cours (n)
;r10 : sous liste actuel
;rbx : fin ancienne liste
;r12 : fin nouvelle liste
;r13: n_pos de l'insertion
;r14: nieme dans la nouvelle liste
;r15: placeholder ebx

;renvoie
;rax debut espace alouer
;rbx debut de la liste
;rcx fin de la liste

permutations:

   mov r9, 1   ;met l etape a 1

   mov rdi, 0
   call ask_brk  ;cherche le debut la fin du heap

   mov [debut_espace_aloue], rax 
   mov rdx, rax   ;garde la fin du heap en memoir
   mov r10, rax   ;affecte debut ancienne liste

   lea rdi, [rdx + 8]
   call ask_brk   ; alloue 8 d espace

   mov byte [rdx], 1 ;affecte 1 a l adresse edx+1

   mov rbx, rax ; met la fin du heap dans 
   mov r12, rax ; met la fin du heap dans 

   call permutations_rec

   ; return 
   mov rax, debut_espace_aloue ; debut de la zone ou la memoire est prise
   mov rcx, r12       ;debut de la liste
   ret

permutations_rec:
   cmp r9, r8
   jge rec_fin ;regarde si n = max n si oui stop la foction sinon fait la rec a n+1
   inc r9

   ;met fin nouvelle list dans fin ancienne
   mov rbx, r12

   call permutations_changant_l
   call permutations_rec
   ret

permutations_changant_l:
   
   cmp r10,rbx
   jge rec_fin

   mov r13, 0
   call permutations_n_dans_liste_actuel
   
   ;add r10, 8*(r9 -1)
   mov r11, 1
deb_mul:
   cmp r11, r9
   jge fin_mult
   add r10, 8
   inc r11
   jmp deb_mul
fin_mult:

   call permutations_changant_l
   ret


permutations_n_dans_liste_actuel:
   cmp r13, r9
   jge rec_fin    ;si n_pos >= n on stop

   mov r14, 0
   call ajouter_niem_element

   ;fin
   inc r13
   call permutations_n_dans_liste_actuel
   ret
   

;ajoute un nouvelle element a la nouvelle liste jusqu a permutations en cours (n)
;entrers r9 r10 r12 r13 r14
;modifie r12
ajouter_niem_element:

   lea rdi, [r12+8]
   call ask_brk  ; ajoute 8 au heap

   ; inc r12
   cmp r14, r13
   je cas_r14_e_r13
   jg cas_r14_g_r13
   mov r15, [r10 + 8*r14]
   mov [r12], r15
   
   jmp fin_ajouter_niem_element

cas_r14_e_r13:

   mov [r12], r9

   jmp fin_ajouter_niem_element

cas_r14_g_r13:

   dec r14 ;change pr avoir le k ieme - 1 element de l ancienne liste
   mov r15, [r10 + 8*r14]
   mov [r12], r15
   inc r14 ;remet a la normal

   jmp fin_ajouter_niem_element

fin_ajouter_niem_element:

   mov r12, rax ; update la fin de la liste
   inc r14      ; incremente le conteur la prochaine element a ajouter est le k-ieme+1
   
   cmp r14, r9
   jge rec_fin      
   call ajouter_niem_element  ;regarde si la liste est fini


rec_fin:
   ret



section .data
   m1 db '['
   m2 db '],['
   m3 db ']',0xa

   affiche_place db 0

   nb_perm equ 10

   debut_espace_aloue dd 0
