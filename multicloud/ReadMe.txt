    Первое облако находится в России (Yandex Cloud), а второе облако в Германии (Google Cloud Platform). Фактически оба облака полностью
дублируют друг друга и представляют собой автономные системы. Оба облака используются исключительно для Prod-окружения.В облаках 
развернут кластер Kubernetes в котором поднимается приложение из 3 сервисов, настроены VPA и HPA. Все исходные коды, GitLab CI/CD piplines,
артефакты Nexus должны храниться только на собственном сервере. Обязательно должны быть настроены хотя бы бекапы по расписанию для БД 
PostgreSQL и MongoDB (в идеале репликации) , а также синхронизация S3-бакетов c обоих облаков на собственный сервер. 
Docker образы для удобства складываем в облака, но обязательно храним копии на своем сервере. Облака - классное решение для Prod-окружений,
но всегда следует помнить, что в облаке ты своему приложению не хозяин. Аккаунт в облаке по какой-либо причине могут внезапно заблокировать.
Должна быть обеспечена возможность с наименьшими потерями переехать в другое облако.

Плюсы:
    + Наименьшее расстояние до пользователя, что обеспечивает более высокую и стабильную работу с точки зрения пользователя и сервиса.
    + Соблюдение законов ЕС о хранении пользовательских данных.
    + Не нужно поддерживать собственную Prod-инфраструктуру.


Минусы:
    - Относительно дорогое решение.
    - Требует больше изменений в коде продукта, помимо различных адресов баз данных и других URL для статических файлов.
    - Без собственного сервера все равно не обойтись, хотя бы для Dev-окружения. Нельзя полностью полагаться только на облака.
