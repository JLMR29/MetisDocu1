classdef Pendulum < System

    %% Pendulum system in 2 or 3 dimensions

    methods

        function self = Pendulum(CONFIG)
            self.nBODIES      = 1;
            self.mCONSTRAINTS = 1;
            self.DIM          = CONFIG.DIM;
            self.MASS         = CONFIG.MASS;
            self.MASS_MAT     = self.MASS*eye(CONFIG.DIM);
            self.nDOF         = self.nBODIES*CONFIG.DIM;
            self.EXT_ACC      = repmat(CONFIG.EXT_ACC,self.nBODIES,1);
            self.GEOM(1)      = norm(CONFIG.Q_0(1:CONFIG.DIM)); %length of pendulum
        end

        function self = initialise(self, CONFIG, this_integrator)
            % Set initial values
            self.z       = zeros(this_integrator.NT, this_integrator.nVARS);
            self.z(1, :) = [CONFIG.Q_0', (self.MASS_MAT * CONFIG.V_0)', this_integrator.LM0'];
        end
        
        function V = potential(self, q)
            V = (self.MASS_MAT*self.EXT_ACC)'*q;
        end
        
        function DV = potential_gradient(self,~)
            DV = self.MASS_MAT*self.EXT_ACC;
        end
        
        function D2V = potential_hessian(~,q)
            D2V = zeros(size(q,1));
        end

        function g = constraint(self, q)
            % Constraint on position level
            g = 0.5 * (q' * q - self.GEOM(1)^2);
        end

        function Dg = constraint_gradient(~, q)
            % Gradient of constraint w.r.t q
            Dg = q';
        end

        function D2g = constraint_hessian(~,q,~)
            % Hessian of g_1 w.r.t. q
            D2g = eye(size(q,1));
        end
        
        function give_animation(self,fig)
            
                DIM = self.DIM;
                q = self.z(:, 1:DIM);
                l = sum(self.GEOM(:));
                NT = size(q,1);

                axis equal
                axis([-1.1 * l, 1.1 * l, -1.1 * l, 1.1 * l, -1.1 * l, 1.1 * l]);
                xlabel('x');
                ylabel('y');
                zlabel('z');
                grid on;

                xa = q(1, 1);
                ya = q(1, 2);
                if DIM == 3
                    za = q(1, 3);
                else
                    za = 0;
                end

                for j = 1:NT

                    cla(fig);
                    hold on

                    %% Current position
                    x = q(j, 1);
                    y = q(j, 2);
                    if DIM == 3
                        z = q(j, 3);
                    else
                        z = 0;
                    end

                    %% Reference sphere
                    plot3(xa, ya, za, 'mo', 'MarkerSize', 10, 'MarkerEdgeColor', [0.75, 0, 0], 'MarkerFaceColor', [0.75, 0, 0]);
                    hold on

                    %% Reference constraint
                    x3 = [0; xa];
                    y3 = [0; ya];
                    z3 = [0; za];
                    plot3(x3, y3, z3, 'k', 'LineWidth', 1);

                    %% current position of the mass
                    hold on
                    if DIM == 3
                        plot3(q(1:j, 1), q(1:j, 2), q(1:j, 3), 'k');
                    else
                        plot3(q(1:j, 1), q(1:j, 2), zeros(j, 1), 'k');
                    end
                    plot3(x, y, z, 'mo', 'MarkerSize', 10, 'MarkerEdgeColor', [1, 0, 0], 'MarkerFaceColor', [0.75, 0, 0]);
                    grid on

                    %% current position of the constraint
                    x3 = [0; x];
                    y3 = [0; y];
                    z3 = [0; z];
                    plot3(x3, y3, z3, 'k', 'linewidth', 1);
                    if DIM == 2
                        view(0, 90)
                    else
                        view(136, 23)
                    end

                    drawnow
                    
                end
                
        end

    end

end
