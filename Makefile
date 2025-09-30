build:
	docker compose up --build -d --remove-orphans
up:
	docker compose up -d
down:
	docker compose down
down-v:
	docker compose down -v
show-logs:
	docker compose logs
show-logs-web:
	docker compose logs web
show-logs-postgres:
	docker compose logs postgres
show-logs-nginx:
	docker compose logs nginx
makemigrations:
	docker compose run --rm web python manage.py makemigrations
migrate:
	docker compose run --rm web python manage.py migrate
collectstatic:
	docker compose run --rm web python manage.py collectstatic --noinput --clear
superuser:
	docker compose run --rm web python manage.py createsuperuser
shell:
	docker compose run --rm web python manage.py shell
db-volume:
	docker volume inspect managehub_managehub_web_postgres_data
managehub-db:
	docker compose exec postgres psql --user=postgres --dbname=managehub_db
restart:
	docker compose restart
rebuild:
	docker compose down && docker compose up --build -d
clean:
	docker system prune -f
clean-all:
	docker system prune -af --volumes
dummy-user:
	docker compose run --rm web python manage.py create_dummy_users
dummy-project:
	docker compose run --rm web python manage.py create_dummy_projects
dummy-employee:
	docker compose run --rm web python manage.py create_dummy_employees
dummy-department:
	docker compose run --rm web python manage.py create_dummy_departments
dummy-leave:
	docker compose run --rm web python manage.py create_dummy_leave_requests
dummy-task:
	docker compose run --rm web python manage.py create_dummy_tasks
dummy-all:
	docker compose run --rm web python manage.py create_dummy_users && \
	docker compose run --rm web python manage.py create_dummy_departments && \
	docker compose run --rm web python manage.py create_dummy_employees && \
	docker compose run --rm web python manage.py create_dummy_projects && \
	docker compose run --rm web python manage.py create_dummy_tasks && \
	docker compose run --rm web python manage.py create_dummy_leave_requests
reset-db:
	docker compose down && \
	docker volume rm managehub_managehub_web_postgres_data || true && \
	docker compose up -d postgres && \
	sleep 5 && \
	docker compose run --rm web python manage.py migrate && \
	docker compose run --rm web python manage.py createsuperuser --noinput --username admin --email admin@managehub.com || true
flush-db:
	docker compose run --rm web python manage.py flush --noinput
backup-db:
	docker compose exec postgres pg_dump -U postgres managehub_db > backup_$(shell date +%Y%m%d_%H%M%S).sql
restore-db:
	@echo "Usage: make restore-db FILE=backup_file.sql"
	docker compose exec -T postgres psql -U postgres managehub_db < $(FILE)
test:
	docker compose run --rm web python manage.py test
test-coverage:
	docker compose run --rm web coverage run --source='.' manage.py test && \
	docker compose run --rm web coverage report
lint:
	docker compose run --rm web flake8 .
format:
	docker compose run --rm web black . && \
	docker compose run --rm web isort .
check:
	docker compose run --rm web python manage.py check
clear-cache:
	docker compose run --rm web python manage.py clear_cache || \
	docker compose run --rm web python -c "from django.core.cache import cache; cache.clear()"
clear-sessions:
	docker compose run --rm web python manage.py clearsessions
load-fixtures:
	docker compose run --rm web python manage.py loaddata fixtures/*.json
dump-data:
	docker compose run --rm web python manage.py dumpdata --natural-foreign --natural-primary > fixtures/data_$(shell date +%Y%m%d_%H%M%S).json
health-check:
	@echo "Checking container health..."
	docker compose ps
	@echo "Checking database connection..."
	docker compose exec web python manage.py check --database default
logs-tail:
	docker compose logs -f
logs-web-tail:
	docker compose logs -f web
stats:
	docker stats $(shell docker compose ps -q)
quick-start:
	make build && make migrate && make dummy-all